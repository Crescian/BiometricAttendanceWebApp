import os
import re
import json
import math
import csv
import threading
import tempfile
import logging
import argparse
import datetime
from datetime import timedelta
import pandas as pd
import numpy as np
import holidays
import psycopg2
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from urllib.parse import quote_plus
import openpyxl
from openpyxl import load_workbook
from openpyxl.drawing.image import Image
from openpyxl.styles import Alignment, Font, Border, Side, PatternFill
from openpyxl.utils import get_column_letter, column_index_from_string

for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)
# Configure logging
logging.basicConfig(
    filename='app.log',       # Log file name
    filemode='w',             # 'a' to append, 'w' to overwrite
    format='%(asctime)s - %(levelname)s - %(message)s',  # Log format
    level=logging.DEBUG        # Minimum level of messages to log
)
engine = create_engine(
    "postgresql+psycopg2://postgres:ITadmin%4000404@localhost/hour_track"
)
# current date format of daily attendance is mm/dd/yyyy

conn = psycopg2.connect(
    host="localhost",
    database="hour_track",
    user="postgres",
    password="ITadmin@00404",
    port="5432"
)

# Shared variables
conversion_result = None
rd_ot_variable = 0




def convert_file(input_csv_file,output_directory, biometric_imports_id):
    """Start the conversion process in a separate thread."""
    global conversion_result
    thread = threading.Thread(target=perform_conversion, args=(input_csv_file,output_directory, biometric_imports_id))
    thread.start()
    thread.join()  # Wait for the thread to finish before proceeding
    return conversion_result  # Return the result after the thread finishes



def perform_conversion(file_path, output_directory, biometric_imports_id):
    """
    Converts input Excel or CSV file to a formatted CSV.
    Adds Earliest, Latest, Punch time columns.
    Skips 1 row.
    Handles night shifts correctly (spanning two dates) using schedules from file.
    """

    global conversion_result

    try:
       
        logging.info("=== START: perform_conversion ===")
        logging.info(f"File path: {file_path}")
        logging.info(f"Output directory: {output_directory}")

        # --- Step 1: Load temp schedule directly from DB table ---
        logging.info("Loading schedule_adjustments + employee_management join...")
        temp_sched = {}
        query = """
            SELECT * FROM schedule_adjustments 
            INNER JOIN employee_management 
            ON employee_management.id = schedule_adjustments.employee_management_id
        """
        temp_sched_pd = pd.read_sql(query, engine)
        logging.info(f"Loaded {len(temp_sched_pd)} temporary schedule rows.")

        for _, row in temp_sched_pd.iterrows():
            employee_name = row["employee_name"].strip()
            date_str = str(row["record_date"]).split(" ")[0]
            raw_sched = str(row["schedule"])
            import re
            matches = re.findall(r"\b\d{1,2}-\d{1,2}\b", raw_sched)
            schedule = matches[0] if matches else ""
            if employee_name not in temp_sched:
                temp_sched[employee_name] = {}
            temp_sched[employee_name][date_str] = schedule

        logging.info(f"Temp schedule dict created for {len(temp_sched)} employees.")

        # --- Step 2: Load schedules from employee_management table ---
        logging.info("Loading employee_management schedules...")
        schedules = {}
        relievers = {}
        query = "SELECT employee_name, schedule,relievers FROM employee_management"
        schedules_pd = pd.read_sql(query, engine)
        logging.info(f"Loaded {len(schedules_pd)} employee schedules.")

        for _, row in schedules_pd.iterrows():
            name = row["employee_name"].strip()
            schedules[name] = str(row["schedule"]).strip()
            relievers[name] = bool(row.get("relievers", False))

        # --- Step 3: Load Excel or CSV attendance ---
        if not os.path.exists(file_path):
            logging.info("Input file does not exist.")
            return None

        logging.info("Loading attendance file...")
        if file_path.lower().endswith(('.xls', '.xlsx')):
            df = pd.read_excel(file_path, skiprows=1)
        else:
            try:
                df = pd.read_csv(file_path, skiprows=1, encoding='utf-8-sig')
            except UnicodeDecodeError:
                df = pd.read_csv(file_path, skiprows=1, encoding='ISO-8859-1')

        logging.info(f"Loaded attendance file with {len(df)} rows.")

        if df.empty:
            logging.info("File is empty after skipping the first row.")
            return None

        # --- Step 4: Prepare data ---
        logging.info("Preparing data (datetime parsing, sorting)...")
        df["Attendance time"] = pd.to_datetime(df["Attendance time"], errors='coerce')
        df = df.dropna(subset=["Attendance time"])
        df = df.sort_values(by=["Personnel ID", "Attendance time"], ascending=True)
        logging.info(f"Remaining valid attendance records: {len(df)}")

        records = []
        processed_count = 0
        late = False
        late_hours = 0
        late_minutes = 0

        for pid, emp_group in df.groupby("Personnel ID"):
            emp_group = emp_group.sort_values("Attendance time")
            first_name = emp_group.iloc[0]["First Name"].strip()
            last_name = emp_group.iloc[0]["Last Name"].strip()
            employee_name = last_name + ", " + first_name

            night_shift_codes = ("18-6", "19-7", "19-4", "20-5", "15-23", "15-24", "23-7", "23-8")

            temp_schedules = temp_sched.get(employee_name, {})
            normal_schedule = schedules.get(employee_name)

            has_night_shift = any(s in night_shift_codes for s in temp_schedules.values()) or (
                normal_schedule in night_shift_codes
            )

            if not temp_schedules and not normal_schedule:
                logging.info(f"No schedule found for {employee_name}, skipping...")
                continue

            # check the row["reliever"] is true
            # --- RELIEVER: preserve your NIGHT/DAY finish logic but avoid double-processing ---
            # --- RELIEVER: decide shift_type by punch closeness to 07 or 19, then run finished DAY/NIGHT logic ---
            # --- RELIEVER: simple, reliable pairing for 7-19 or 19-7 only ---
            is_reliever = relievers.get(employee_name, False)
            if is_reliever:
                logging.info(f"Processing {employee_name} as RELIEVER with mixed shifts.")

                punches = emp_group["Attendance time"].tolist()
                if not punches:
                    logging.info(f"No punches for reliever {employee_name}, skipping.")
                    continue

                # For relievers, we need to determine shift type based on the pattern
                # Group punches by date first
                punches_by_date = {}
                for punch in punches:
                    date_key = punch.date()
                    if date_key not in punches_by_date:
                        punches_by_date[date_key] = []
                    punches_by_date[date_key].append(punch)
                
                # Sort punches within each date
                for date_key in punches_by_date:
                    punches_by_date[date_key].sort()
                
                logging.info(f"Reliever {employee_name} punches by date:")
                for date_key in sorted(punches_by_date.keys()):
                    day_punches = punches_by_date[date_key]
                    logging.info(f"  {date_key}: {[p.strftime('%H:%M:%S') for p in day_punches]}")
                
                used_punches = set()
                
                # Process each date
                for date_key in sorted(punches_by_date.keys()):
                    day_punches = punches_by_date[date_key]
                    
                    # Check if we have punches for next day (NIGHT shift)
                    next_date = date_key + pd.Timedelta(days=1)
                    next_day_punches = punches_by_date.get(next_date, [])
                    
                    # Try NIGHT shift first (evening punch + next day morning punch)
                    if next_day_punches:
                        evening_punch = None
                        morning_punch = None
                        
                        # Find evening punch from current day
                        for punch in day_punches:
                            if punch not in used_punches and punch.hour >= 12:
                                evening_punch = punch
                                break
                        
                        # Find morning punch from next day
                        for punch in next_day_punches:
                            if punch not in used_punches and punch.hour < 12:
                                morning_punch = punch
                                break
                        
                        if evening_punch and morning_punch:
                            # NIGHT shift: evening IN to next day morning OUT
                            used_punches.add(evening_punch)
                            used_punches.add(morning_punch)
                            
                            record_date_str = date_key.strftime('%Y-%m-%d')
                            row = emp_group.iloc[-1].copy()
                            row["employee_name"] = employee_name
                            row["record_date"] = record_date_str
                            row["earliest_time"] = evening_punch.strftime('%H:%M:%S')
                            row["latest_time"] = morning_punch.strftime('%H:%M:%S')
                            # === LATE VALIDATION ===
                            try:
                                start_hour, end_hour = map(int, schedule.split("-"))
                                date_base = pd.Timestamp(date)
                                start_required = pd.Timedelta(hours=start_hour)
                                late_cutoff = date_base + start_required + pd.Timedelta(minutes=1)
                                morning_limit = date_base + pd.Timedelta(hours=12)

                                late = False
                                late_hours = late_minutes = 0

                                # Check lateness using earliest only
                                if date_base <= earliest < morning_limit and earliest > late_cutoff:
                                    late = True
                                    delta = earliest - (date_base + start_required)
                                    late_hours = delta.components.hours
                                    late_minutes = delta.components.minutes

                                    # bump by 1 hour if less than 1 hr late
                                    if delta < pd.Timedelta(hours=1):
                                        earliest = earliest.floor("h") + pd.Timedelta(hours=1)
                                        delta = earliest - (date_base + start_required)
                                        late_hours = delta.components.hours
                                        late_minutes = delta.components.minutes

                                logging.info(f"{employee_name} | {date_str} | Late={late} ({late_hours}h {late_minutes}m)")
                                row["is_late"] = late
                                row["late_hours"] = late_hours
                                row["late_minutes"] = late_minutes
                            except Exception as e:
                                logging.info(f"Late validation error for {employee_name} on {date_str}: {e}")
                            # === END LATE VALIDATION ===
                            row["Punch Time"] = f"{evening_punch.strftime('%H:%M:%S')};{morning_punch.strftime('%H:%M:%S')}"
                            row["shift_type"] = "NIGHT"
                            
                            records.append(row)
                            processed_count += 1
                            
                            logging.info(
                                f"Reliever {employee_name} | NIGHT | Earliest={evening_punch.strftime('%Y-%m-%d %H:%M:%S')} "
                                f"| Latest={morning_punch.strftime('%Y-%m-%d %H:%M:%S')} | pair_count=2"
                            )
                            continue  # Skip DAY shift processing for this date
                    
                    # Process DAY shift (same day punches)
                    if len(day_punches) >= 2:
                        # Find morning and evening punches for DAY shift
                        morning_punch = None
                        evening_punch = None
                        
                        for punch in day_punches:
                            if punch not in used_punches:
                                if punch.hour < 12:  # Morning punch
                                    morning_punch = punch
                                elif punch.hour >= 12:  # Evening punch
                                    evening_punch = punch
                        
                        if morning_punch and evening_punch:
                            # DAY shift: morning IN to evening OUT
                            used_punches.add(morning_punch)
                            used_punches.add(evening_punch)
                            
                            record_date_str = date_key.strftime('%Y-%m-%d')
                            row = emp_group.iloc[-1].copy()
                            row["employee_name"] = employee_name
                            row["record_date"] = record_date_str
                            row["earliest_time"] = morning_punch.strftime('%H:%M:%S')
                            row["latest_time"] = evening_punch.strftime('%H:%M:%S')
                            # === LATE VALIDATION ===
                            try:
                                start_hour, end_hour = map(int, schedule.split("-"))
                                date_base = pd.Timestamp(date)
                                start_required = pd.Timedelta(hours=start_hour)
                                late_cutoff = date_base + start_required + pd.Timedelta(minutes=1)
                                morning_limit = date_base + pd.Timedelta(hours=12)

                                late = False
                                late_hours = late_minutes = 0

                                # Check lateness using earliest only
                                if date_base <= earliest < morning_limit and earliest > late_cutoff:
                                    late = True
                                    delta = earliest - (date_base + start_required)
                                    late_hours = delta.components.hours
                                    late_minutes = delta.components.minutes

                                    # bump by 1 hour if less than 1 hr late
                                    if delta < pd.Timedelta(hours=1):
                                        earliest = earliest.floor("h") + pd.Timedelta(hours=1)
                                        delta = earliest - (date_base + start_required)
                                        late_hours = delta.components.hours
                                        late_minutes = delta.components.minutes

                                logging.info(f"{employee_name} | {date_str} | Late={late} ({late_hours}h {late_minutes}m)")
                                row["is_late"] = late
                                row["late_hours"] = late_hours
                                row["late_minutes"] = late_minutes
                            except Exception as e:
                                logging.info(f"Late validation error for {employee_name} on {date_str}: {e}")
                            # === END LATE VALIDATION ===
                            row["Punch Time"] = f"{morning_punch.strftime('%H:%M:%S')};{evening_punch.strftime('%H:%M:%S')}"
                            row["shift_type"] = "DAY"
                            
                            records.append(row)
                            processed_count += 1
                            
                            logging.info(
                                f"Reliever {employee_name} | DAY | Earliest={morning_punch.strftime('%Y-%m-%d %H:%M:%S')} "
                                f"| Latest={evening_punch.strftime('%Y-%m-%d %H:%M:%S')} | pair_count=2"
                            )

                # done processing reliever — skip generic day/night for this employee
                continue

            logging.info(f"Processing {employee_name} | NightShift={has_night_shift} | Temp={temp_schedules} | Normal={normal_schedule}")

            # ---- NIGHT SHIFT ----
            if has_night_shift:
                
                punches = emp_group["Attendance time"].sort_values().tolist()
                used = [False] * len(punches)
                evening_punches = [(i, p) for i, p in enumerate(punches) if p.hour >= 14]

                for evening_idx, evening_punch in evening_punches:
                    if used[evening_idx]:
                        continue
                    date_str = evening_punch.date().strftime('%Y-%m-%d')
                    schedule = temp_schedules.get(date_str, normal_schedule)
                    if not schedule:
                        logging.info(f"No schedule for {employee_name} on {date_str}, skipping.")
                        continue
                    try:
                        start_hour, end_hour = map(int, schedule.split("-"))
                    except Exception:
                        logging.info(f"Invalid schedule format {schedule} for {employee_name}.")
                        continue

                    shift_punches = [evening_punch]
                    used[evening_idx] = True
                    shift_start = evening_punch
                    shift_end_limit = shift_start + pd.Timedelta(hours=12)

                    for j, punch in enumerate(punches):
                        if not used[j] and shift_start < punch <= shift_end_limit:
                            shift_punches.append(punch)
                            used[j] = True

                    shift_punches.sort()
                    earliest = shift_punches[0]
                    latest = shift_punches[-1]

                    row = emp_group.iloc[-1].copy()
                    row["record_date"] = shift_punches[0].date().strftime('%Y-%m-%d')
                    row["earliest_time"] = earliest.strftime('%H:%M:%S')
                    row["latest_time"] = latest.strftime('%H:%M:%S')
                    # === LATE VALIDATION ===
                    try:
                        start_hour, end_hour = map(int, schedule.split("-"))
                        date_base = pd.Timestamp(date)
                        start_required = pd.Timedelta(hours=start_hour)
                        late_cutoff = date_base + start_required + pd.Timedelta(minutes=1)
                        morning_limit = date_base + pd.Timedelta(hours=12)

                        late = False
                        late_hours = late_minutes = 0

                        # Check lateness using earliest only
                        if date_base <= earliest < morning_limit and earliest > late_cutoff:
                            late = True
                            delta = earliest - (date_base + start_required)
                            late_hours = delta.components.hours
                            late_minutes = delta.components.minutes

                            # bump by 1 hour if less than 1 hr late
                            if delta < pd.Timedelta(hours=1):
                                earliest = earliest.floor("h") + pd.Timedelta(hours=1)
                                delta = earliest - (date_base + start_required)
                                late_hours = delta.components.hours
                                late_minutes = delta.components.minutes

                        logging.info(f"{employee_name} | {date_str} | Late={late} ({late_hours}h {late_minutes}m)")
                        row["is_late"] = late
                        row["late_hours"] = late_hours
                        row["late_minutes"] = late_minutes
                    except Exception as e:
                        logging.info(f"Late validation error for {employee_name} on {date_str}: {e}")
                    # === END LATE VALIDATION ===
                    row["Punch Time"] = f"{earliest.strftime('%H:%M:%S')};{latest.strftime('%H:%M:%S')}"
                    row["employee_name"] = employee_name
                    records.append(row)
                    processed_count += 1

            # ---- DAY SHIFT ----
            else:
                emp_group["DateOnly"] = emp_group["Attendance time"].dt.date
                for date, day_group in emp_group.groupby("DateOnly"):
                    date_str = date.strftime('%Y-%m-%d')
                    schedule = temp_schedules.get(date_str, normal_schedule)
                    if not schedule:
                        logging.info(f"No schedule for {employee_name} on {date_str}, skipping...")
                        continue
                    day_group = day_group.sort_values("Attendance time")
                    earliest = day_group["Attendance time"].min()
                    latest = day_group["Attendance time"].max()
                    row = day_group.iloc[-1].copy()
                    row["record_date"] = earliest.strftime('%m/%d/%Y')
                    row["earliest_time"] = earliest.strftime('%H:%M:%S')
                    row["latest_time"] = latest.strftime('%H:%M:%S')
                    # === LATE VALIDATION ===
                    try:
                        start_hour, end_hour = map(int, schedule.split("-"))
                        date_base = pd.Timestamp(date)
                        start_required = pd.Timedelta(hours=start_hour)
                        late_cutoff = date_base + start_required + pd.Timedelta(minutes=1)
                        morning_limit = date_base + pd.Timedelta(hours=12)

                        late = False
                        late_hours = late_minutes = 0

                        # Check lateness using earliest only
                        if date_base <= earliest < morning_limit and earliest > late_cutoff:
                            late = True
                            delta = earliest - (date_base + start_required)
                            late_hours = delta.components.hours
                            late_minutes = delta.components.minutes

                            # bump by 1 hour if less than 1 hr late
                            if delta < pd.Timedelta(hours=1):
                                earliest = earliest.floor("h") + pd.Timedelta(hours=1)
                                delta = earliest - (date_base + start_required)
                                late_hours = delta.components.hours
                                late_minutes = delta.components.minutes

                        logging.info(f"{employee_name} | {date_str} | Late={late} ({late_hours}h {late_minutes}m)")
                        row["is_late"] = late
                        row["late_hours"] = late_hours
                        row["late_minutes"] = late_minutes
                    except Exception as e:
                        logging.info(f"Late validation error for {employee_name} on {date_str}: {e}")
                    # === END LATE VALIDATION ===

                    row["employee_name"] = employee_name
                    row["Punch Time"] = (
                        f"{earliest.strftime('%H:%M:%S')};{latest.strftime('%H:%M:%S')}"
                        if len(day_group) > 1 else earliest.strftime('%H:%M:%S')
                    )
                    records.append(row)
                    processed_count += 1

        logging.info(f"Total processed records: {processed_count}")

        if not records:
            logging.info("No attendance records found after processing.")
            return None

        df_processed = pd.DataFrame(records)
        if "DateOnly" in df_processed.columns:
            df_processed.drop(columns=["DateOnly"], inplace=True)
        logging.info(f"Processed DataFrame has {len(df_processed)} rows.")

       
        # --- INSERT INTO attendance_records ---
       
        with engine.connect() as connection:
            logging.info("Starting DB insertions...")
            for _, row in df_processed.iterrows():
                full_name = row.get("employee_name")
                if not full_name or pd.isna(full_name):
                    logging.info("Skipping row with missing employee_name.")
                    continue

                emp_query = text("SELECT id FROM employee_management WHERE employee_name = :employee_name LIMIT 1")
                emp_result = connection.execute(emp_query, {"employee_name": full_name}).fetchone()

                if not emp_result:
                    logging.info(f"Skipping {full_name} — not found in employee_management table.")
                    continue

                employee_management_id = emp_result[0]
                record_date = str(row["record_date"]).strip()
                if "/" in record_date:
                    parts = record_date.split("/")
                    if len(parts) == 3:
                        record_date = f"{parts[2]}-{parts[0].zfill(2)}-{parts[1].zfill(2)}"
                if " " in record_date:
                    record_date = record_date.split(" ")[0]

                weekday = datetime.datetime.strptime(record_date, "%Y-%m-%d").strftime("%A")

                
                ## CHECK for same earliest and latest and continue
                # --- NEW CHECK: skip if earliest and latest time are the same ---
                earliest_time = row["earliest_time"]
                latest_time = row["latest_time"]
                if earliest_time == latest_time:
                    logging.info(f"Skipping {full_name} on {record_date} — same earliest and latest time ({earliest_time}).")
                    continue

                # --- VALIDATION: Check for existing record ---
                validate_query = text("""
                    SELECT 1 FROM attendance_records
                    WHERE employee_management_id = :employee_management_id
                    AND record_date = :record_date
                    AND earliest_time = :earliest_time
                    AND latest_time = :latest_time
                    AND weekday = :weekday
                    AND biometric_imports_id = :biometric_imports_id
                    LIMIT 1
                """)
                exists = connection.execute(validate_query, {
                    "employee_management_id": employee_management_id,
                    "record_date": record_date,
                    "earliest_time": row["earliest_time"],
                    "latest_time": row["latest_time"],
                    "weekday": weekday,
                    "biometric_imports_id": biometric_imports_id
                }).fetchone()

                if exists:
                    logging.info(f"Skipping duplicate record for {full_name} on {record_date}")
                    continue

                leave_query = text("""
                    SELECT id 
                    FROM leaves
                    WHERE employee_management_id = :employee_management_id
                    AND record_date = :record_date
                    AND status = 'Approved'
                    AND biometric_imports_id = :biometric_imports_id
                    LIMIT 1
                """)
                leave_result = connection.execute(leave_query, {
                    "employee_management_id": employee_management_id,
                    "record_date": record_date,
                    "biometric_imports_id": biometric_imports_id
                }).fetchone()
                leave = False
                leave_id = None
                if leave_result:
                    leave = True
                    leave_id = leave_result.id
                    logging.info(f"Approved leave detected for {full_name} on {record_date}.")

                

                # --- Prepare parameters ---
                params = {
                    "employee_management_id": employee_management_id,
                    "attendance_area": row.get("Attendance Area"),
                    "attendance_point_name": row.get("Attendance Point Name"),
                    "verification_mode": row.get("Verification Mode"),
                    "attendance_photo": row.get("Attendance Photo"),
                    "data_sources": row.get("Data Sources"),
                    "record_date": record_date,
                    "earliest_time": row["earliest_time"],
                    "latest_time": row["latest_time"],
                    "weekday": weekday,
                    "biometric_imports_id": biometric_imports_id,
                    "late": late,
                    "late_hours": late_hours,
                    "late_minutes": late_minutes,
                    "leaves": leave
                }

                # --- INSERT and get last inserted ID in one step ---
                insert_query = text("""
                    INSERT INTO attendance_records (
                        employee_management_id, attendance_area, attendance_point_name,
                        verification_mode, attendance_photo, data_sources, record_date,
                        earliest_time, latest_time, weekday, biometric_imports_id,
                        created_at, updated_at, late, late_hours, late_minutes, leaves
                    )
                    VALUES (
                        :employee_management_id, :attendance_area, :attendance_point_name,
                        :verification_mode, :attendance_photo, :data_sources, :record_date,
                        :earliest_time, :latest_time, :weekday, :biometric_imports_id,
                        NOW(), NOW(), :late, :late_hours, :late_minutes, :leaves
                    )
                    RETURNING id
                """)

                last_insert_id = connection.execute(insert_query, params).scalar()

                # --- Update leaves table only if this was a leave day ---
                if leave_id:
                    update_leave_query = text("""
                        UPDATE leaves
                        SET attendance_records_id = :attendance_records_id
                        WHERE id = :leave_id
                    """)
                    connection.execute(update_leave_query, {
                        "attendance_records_id": last_insert_id,
                        "leave_id": leave_id
                    })
                    logging.info(f"Linked leave ID {leave_id} → attendance_records_id {last_insert_id}")

                connection.commit()

        logging.info("Attendance records successfully inserted into attendance_records table.")
        conversion_result = "Inserted into attendance_records table"
        return conversion_result


    except Exception as e:
        logging.exception(f"Error converting file: {e}")
        return None


def load_data_from_db(biometric_imports_id):
    """Reads attendance_records joined with employee_management and returns DataFrames."""
    try:
       
        # Define the SQL query once (no trailing comma!)
        query = f"""
            SELECT 
                ar.id,
                ar.employee_management_id,
                em.employee_name,
                em.department,
                em.unique_id,
                em.basic_salary,
                ar.record_date,
                ar.earliest_time,
                ar.latest_time,
                ar.weekday,
                ar.biometric_imports_id,
                ar.leaves
            FROM attendance_records AS ar
            INNER JOIN employee_management AS em
                ON ar.employee_management_id = em.id
            WHERE ar.biometric_imports_id = {biometric_imports_id}
        """

        # Try reading from DB (fallback encoding logic kept for structure)
        try:
            df = pd.read_sql(query, engine)
        except UnicodeDecodeError:
            df = pd.read_sql(query, engine)

        # Load employee_management as data
        try:
            data = pd.read_sql("SELECT * FROM employee_management", engine)
        except UnicodeDecodeError:
            data = pd.read_sql("SELECT * FROM employee_management", engine)

        return df, data

    except Exception as ex:
        logging.info(f"Error reading data: {ex}")
        return None, None



def get_sundays(year):
    """Returns a list of all Sundays in the given year formatted as yyyy-mm-dd."""
    date = datetime.date(year, 1, 1)
    date += datetime.timedelta(days=(6 - date.weekday()) % 7)
    sundays = []
    while date.year == year:
        sundays.append(date.strftime("%Y-%m-%d"))  # Format the date as yyyy-mm-dd
        date += datetime.timedelta(weeks=1)
    return sundays




def calculate_total_non_workingdays(engine=None):
    """
    Inserts Sundays and official holidays into the custom_dates table.
    Fields: id (auto), record_date, title, holiday_type

    If `year` is None, the function uses the current year.
    """
    conn = None
    try:
        # use passed year or fall back to current year
        if year is None:
            year = datetime.datetime.now().year

        conn = engine.connect()

        # 1. Get Sundays for the year (assumes get_sundays(year) returns date strings 'YYYY-MM-DD')
        sundays = get_sundays(year)
        sunday_records = [
            {"record_date": s, "title": "Sunday Rest Day", "holiday_type": "Rest Day"}
            for s in sundays
        ]

        # 2. Define holidays using the variable 'year' (no more hardcoded 2025)
        holidays = [
            (f"{year}-01-01", "New Year's Day", "Regular Holiday"),
            (f"{year}-04-17", "Maundy Thursday", "Regular Holiday"),
            (f"{year}-04-18", "Good Friday", "Regular Holiday"),
            (f"{year}-04-09", "Araw ng Kagitingan (Day of Valor)", "Regular Holiday"),
            (f"{year}-05-01", "Labor Day", "Regular Holiday"),
            (f"{year}-06-06", "Eid’l Adha", "Regular Holiday"),
            (f"{year}-06-12", "Independence Day", "Regular Holiday"),
            (f"{year}-08-25", "National Heroes Day", "Regular Holiday"),
            (f"{year}-11-30", "Bonifacio Day", "Regular Holiday"),
            (f"{year}-12-25", "Christmas Day", "Regular Holiday"),
            (f"{year}-12-30", "Rizal Day", "Regular Holiday"),
            (f"{year}-01-29", "Chinese New Year", "Special Non-Working Holiday"),
            (f"{year}-04-19", "Black Saturday", "Special Non-Working Holiday"),
            (f"{year}-08-21", "Ninoy Aquino Day", "Special Non-Working Holiday"),
            (f"{year}-10-31", "All Saints’ Eve", "Special Non-Working Holiday"),
            (f"{year}-11-01", "All Saints’ Day", "Special Non-Working Holiday"),
            (f"{year}-12-08", "Feast of the Immaculate Conception of Mary", "Special Non-Working Holiday"),
            (f"{year}-12-24", "Christmas Eve", "Special Non-Working Holiday"),
            (f"{year}-12-31", "Last Day of the Year", "Special Non-Working Holiday"),
        ]

        # 3. Build holiday records, annotate if it falls on Sunday
        holiday_records = []
        for d, t, ty in holidays:
            try:
                weekday = datetime.datetime.strptime(d, "%Y-%m-%d").weekday()
                title = t + " (Falls on Rest Day)" if weekday == 6 else t
            except Exception:
                # If the date string parsing fails, keep the original title and continue
                title = t
            holiday_records.append({"record_date": d, "title": title, "holiday_type": ty})

        # 4. Combine and insert (avoid duplicates)
        all_records = sunday_records + holiday_records

        for rec in all_records:
            exists = conn.execute(
                text("SELECT 1 FROM custom_dates WHERE record_date = :record_date AND title = :title"),
                rec
            ).first()
            if not exists:
                conn.execute(
                    text("""
                        INSERT INTO custom_dates (record_date, title, holiday_type)
                        VALUES (:record_date, :title, :holiday_type)
                    """),
                    rec
                )

        conn.commit()
        logging.info(f"Inserted {len(all_records)} non-working days for {year}.")

    except Exception as ex:
        logging.info(f"Error calculating non-working days: {ex}")

    finally:
        if conn is not None:
            try:
                conn.close()
            except Exception:
                pass



def log_overtime_to_db(conn, row,
    ord_ot, rd_ot,
    ord_nd, ord_nd_ot,
    rd_nd, rd_nd_ot,
    rd, total_non_working_days_present,
    late, late_hours, late_minutes,
    out_time_required,
    type, schedule, status, biometric_imports_id, attendance_records_id, schedule_shift, update_target):

    def trim_days(ts):
        s = str(ts or "").strip()
        return re.sub(r"^\d+\s+days?\s+", "", s)

    last = row["employee_name"].split(",")[0].strip()
    first = row["employee_name"].split(",")[1].strip()
    record_date = row.get("record_date")
    if not record_date:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT record_date
                FROM attendance_records
                WHERE id = %s
            """, (attendance_records_id,))
            result = cur.fetchone()
            if result:
                record_date = result[0]
    # earliest    = trim_days(row.get("earliest_time"))
    # latest      = trim_days(row.get("latest_time"))
    # if rd > 0 or rd_ot > 0 or rd_nd_ot > 0:
    #     logging.info(f"Employee name inserted {row["employee_name"]} record date {record_date} type{type} rd{rd} ")
    
    earliest = trim_days(row.get("earliest_time")) if row.get("earliest_time") not in (None, "", 0, "0", "0.0") else "00:00:00"
    latest = trim_days(row.get("latest_time")) if row.get("latest_time") not in (None, "", 0, "0", "0.0") else "00:00:00"
    # latest_time_db = latest if isinstance(latest, str) else str(latest)
    #     if latest_time_db == "0 days 00:00:00":
    #         latest_time = "00:00:00"
    # Convert latest_time properly before logging
    latest_time = row.get("latest_time")
    if latest_time is None or latest_time == pd.Timedelta(0):
        latest_time_db = "00:00:00"
    elif isinstance(latest_time, pd.Timedelta):
        total_seconds = int(latest_time.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        seconds = total_seconds % 60
        latest_time = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
    else:
        latest_time = str(latest_time)
    # Convert latest_time properly before logging
    earliest_time = row.get("earliest_time")
    if earliest_time is None or earliest_time == pd.Timedelta(0):
        earliest_time_db = "00:00:00"
    elif isinstance(earliest_time, pd.Timedelta):
        total_seconds = int(earliest_time.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        seconds = total_seconds % 60
        earliest_time = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
    else:
        earliest_time = str(earliest_time)

     # Fetch unique_id from employee_management using employee_name
    with conn.cursor() as cur:
        cur.execute("""
            SELECT unique_id, department, serial_number
            FROM employee_management
            WHERE employee_name = %s
        """, (row["employee_name"],))
        result = cur.fetchone()

    id_str = result[0] if result else "TMNG-000000-000"
    department = result[1] if result else None
    serial_number = result[2] if result else None

    # id_val = row.get("unique_id")
    # id_str = str(id_val).strip() if pd.notna(id_val) else ""
    # department = row.get("Department Name")
    # serial_number = row.get("Serial Number")
    attendance_area = row.get("Attendance Area")
    # create converter if rd is float convert it to hhmm

    new_entry = {
        "id": id_str or "TMNG-000000-000",
        "first_name": first,
        "last_name":  last,
        "employee_name": f"{last}, {first}",
        "record_date": record_date,
        "earliest_time": earliest_time,
        "latest_time":   latest_time,
        "type": type,
        "department": department,
        "attendance_area": attendance_area,
        "serial_number": serial_number,
        "schedule": schedule,
        "ord_ot": f"{int(ord_ot):02d}:{int(round((ord_ot - int(ord_ot)) * 60)):02d}" if ord_ot is not None else "00:00",
        "rd_ot": f"{int(rd_ot):02d}:{int(round((rd_ot - int(rd_ot)) * 60)):02d}" if rd_ot is not None else "00:00",
        "ord_nd": f"{int(ord_nd):02d}:{int(round((ord_nd - int(ord_nd)) * 60)):02d}" if ord_nd is not None else "00:00",
        "ord_nd_ot": f"{int(ord_nd_ot):02d}:{int(round((ord_nd_ot - int(ord_nd_ot)) * 60)):02d}" if ord_nd_ot is not None else "00:00",
        "rd_nd": f"{int(rd_nd):02d}:{int(round((rd_nd - int(rd_nd)) * 60)):02d}" if rd_nd is not None else "00:00",
        "rd_nd_ot": f"{int(rd_nd_ot):02d}:{int(round((rd_nd_ot - int(rd_nd_ot)) * 60)):02d}" if rd_nd_ot is not None else "00:00",
        # "rd": f"{int(rd):02d}:{int(round((rd - int(rd)) * 60)):02d}" if rd is not None else "00:00",
        "rd": f"{int(rd):02d}:{int((rd % 1) * 60):02d}" if rd is not None else "00:00",
        "total_non_working_days_present": total_non_working_days_present,
        "late": late,
        "late_hours": late_hours,
        "late_minutes": late_minutes,
        "out_time_required": out_time_required,
        'status': status,
        "biometric_imports_id":biometric_imports_id,
        "attendance_records_id":attendance_records_id,
        "schedule_shift":schedule_shift,
        # "sh": sh,
        # "sh_ot": sh_ot,
        # "sh_nd":sh_nd,
        # "sh_nd_ot":sh_nd_ot
        # "lh":lh,
        # "lh_ot":lh_ot,
        # "lh_nd":lh_nd,
        # "lh_nd_ot":lh_nd_ot

    }
    logging.info(f"[CHECK] Looking for existing OT entry: emp={new_entry['employee_name']} date={new_entry['record_date']} type={new_entry['type']} bio_id={new_entry['biometric_imports_id']}")

    try:
        with conn.cursor() as cur:
            # ✅ Duplicate check before insert
            cur.execute("""
                SELECT id, rd, rd_ot, rd_nd, rd_nd_ot, ord_ot, ord_nd, ord_nd_ot, schedule
                FROM overtimes
                WHERE employee_name = %s
                AND record_date = %s
                AND type = %s
                AND biometric_imports_id = %s
                AND attendance_records_id = %s
            """, (new_entry["employee_name"], new_entry["record_date"], new_entry["type"], new_entry["biometric_imports_id"], new_entry["attendance_records_id"]))
            
            existing = cur.fetchone()
            
            if existing:
                existing_id, existing_rd, existing_rd_ot, existing_rd_nd, existing_rd_nd_ot,existing_ord_ot, existing_ord_nd, existing_ord_nd_ot, existing_schedule = existing
                logging.info(f"[FOUND] Existing OT: ID={existing[0]} RD={existing[1]} RD_OT={existing[2]} RD_ND={existing[3]} RD_ND_OT={existing[4]} ORD_OT={existing[5]} ORD_ND={existing[6]} ORD_ND_OT={existing[7]} SCHED={existing[8]}")
                logging.info(f"[NEW] Incoming values → RD={new_entry['rd']} RD_OT={new_entry['rd_ot']} RD_ND={new_entry['rd_nd']} RD_ND_OT={new_entry['rd_nd_ot']} ORD_OT={new_entry['ord_ot']} ORD_ND={new_entry['ord_nd']} ORD_ND_OT={new_entry['ord_nd_ot']}")


                # ==========================
                # ORD UPDATE
                # ==========================
                if new_entry["type"] == "ord":

                    # Check if ORD values changed
                    if (
                        new_entry["ord_ot"] != existing_ord_ot or
                        new_entry["ord_nd"] != existing_ord_nd or
                        new_entry["ord_nd_ot"] != existing_ord_nd_ot):
                        logging.info(f"[ORD UPDATE] ORD values changed: "
                        f"ORD_OT {existing_ord_ot}→{new_entry['ord_ot']} "
                        f"ORD_ND {existing_ord_nd}→{new_entry['ord_nd']} "
                        f"ORD_ND_OT {existing_ord_nd_ot}→{new_entry['ord_nd_ot']}")
                        cur.execute("""
                            UPDATE overtimes
                            SET ord_ot = %s,
                                ord_nd = %s,
                                ord_nd_ot = %s,
                                schedule_shift = %s,
                                schedule = %s
                            WHERE id = %s
                        """, (
                            new_entry["ord_ot"],
                            new_entry["ord_nd"],
                            new_entry["ord_nd_ot"],
                            new_entry["schedule_shift"],
                            new_entry["schedule"],
                            existing_id
                        ))
                        conn.commit()
                        logging.info(
                            f"Updated ORD (incl schedule_shift) for {new_entry['employee_name']} "
                            f"on {new_entry['record_date']}"
                        )

                    else:
                        # Skip if nothing changed
                        logging.info(
                            f"Duplicate entry skipped for {new_entry['employee_name']} on "
                            f"{new_entry['record_date']} ({new_entry['type']})"
                        )
                    return existing_id

                # ==========================
                # RD UPDATE
                # ==========================
                # Add this inside your function, before the RD update block
                update_target = row.get("update_target")  # or pass as an additional argument if needed
                if new_entry["type"] == "rd":
                    if update_target == "rd":
                        logging.info(f"[RD UPDATE] Updating only RD for {new_entry['employee_name']}")
                        cur.execute("""
                            UPDATE overtimes
                            SET rd = %s,
                                schedule_shift = %s,
                                schedule = %s
                            WHERE id = %s
                        """, (new_entry["rd"], new_entry["schedule_shift"], new_entry["schedule"], existing_id))
                        conn.commit()
                    elif update_target == "rd_ot":
                        logging.info(f"[RD OT UPDATE] Updating only RD OT/ND/ND_OT for {new_entry['employee_name']}")
                        cur.execute("""
                            UPDATE overtimes
                            SET rd_ot = %s,
                                rd_nd = %s,
                                rd_nd_ot = %s,
                                schedule_shift = %s,
                                schedule = %s
                            WHERE id = %s
                        """, (new_entry["rd_ot"], new_entry["rd_nd"], new_entry["rd_nd_ot"],
                            new_entry["schedule_shift"], new_entry["schedule"], existing_id))
                        conn.commit()
                    # Always return ID
                    return existing_id

               
                
                



            logging.info(f"[INSERT] Creating new OT entry for {new_entry['employee_name']} "
             f"RD={new_entry['rd']} RD_OT={new_entry['rd_ot']} "
             f"RD_ND={new_entry['rd_nd']} RD_ND_OT={new_entry['rd_nd_ot']} "
             f"ORD_OT={new_entry['ord_ot']} ORD_ND={new_entry['ord_nd']} ORD_ND_OT={new_entry['ord_nd_ot']} TYPE={new_entry['type']}")
            # Proceed to insert only if no duplicate
            cur.execute("""
                INSERT INTO overtimes (
                    unique_id, first_name, last_name, employee_name,
                    earliest_time, latest_time, type, department, attendance_area,
                    serial_number, schedule, ord_ot, rd_ot, ord_nd, ord_nd_ot,
                    rd, rd_nd, rd_nd_ot, total_non_working_days_present, late,
                    late_hours, late_minutes, out_time_required, record_date, status, biometric_imports_id, attendance_records_id, schedule_shift
                )
                VALUES (
                    %(id)s, %(first_name)s, %(last_name)s, %(employee_name)s,
                    %(earliest_time)s, %(latest_time)s, %(type)s,
                    %(department)s, %(attendance_area)s, %(serial_number)s, %(schedule)s,
                    %(ord_ot)s, %(rd_ot)s, %(ord_nd)s, %(ord_nd_ot)s, %(rd)s, %(rd_nd)s, %(rd_nd_ot)s,
                    %(total_non_working_days_present)s, %(late)s, %(late_hours)s, %(late_minutes)s,
                    %(out_time_required)s, %(record_date)s, %(status)s,%(biometric_imports_id)s,%(attendance_records_id)s,%(schedule_shift)s
                )
                RETURNING id
            """, new_entry)
            new_id = cur.fetchone()[0]

        conn.commit()
        return new_id

    except Exception as e:
        conn.rollback()
        logging.info(f"Insert failed:{e}")
        raise



def merge_all_rd_entries(conn):
    """
    Merge all 'RD' type entries in the 'overtimes' table where there are duplicates
    for the same record_date, biometric_imports_id, and attendance_records_id.
    """
    try:
        with conn.cursor() as cur:
            # Find all groups that have duplicates (ignore minor differences in name)
            cur.execute("""
                SELECT record_date, biometric_imports_id, attendance_records_id, COUNT(*)
                FROM overtimes
                WHERE type = 'RD'
                GROUP BY record_date, biometric_imports_id, attendance_records_id
                HAVING COUNT(*) > 1
            """)
            groups = cur.fetchall()
            
            if not groups:
                logging.info("No duplicate RD entries found.")
                return

            for record_date, bio_id, att_id, count in groups:
                # Fetch all duplicates in this group
                cur.execute("""
                    SELECT id, rd, rd_ot, rd_nd, rd_nd_ot
                    FROM overtimes
                    WHERE type = 'RD'
                      AND record_date = %s
                      AND biometric_imports_id = %s
                      AND attendance_records_id = %s
                    ORDER BY id
                """, (record_date, bio_id, att_id))
                
                rows = cur.fetchall()
                if len(rows) < 2:
                    continue  # nothing to merge

                combined = {"rd": "00:00", "rd_ot": "00:00", "rd_nd": "00:00", "rd_nd_ot": "00:00"}
                ids_to_delete = []

                for row in rows:
                    row_id, rd, rd_ot, rd_nd, rd_nd_ot = row
                    ids_to_delete.append(row_id)

                    # Merge values column-wise: keep first non-zero value
                    for key, val in zip(combined.keys(), [rd, rd_ot, rd_nd, rd_nd_ot]):
                        if val != "00:00":
                            combined[key] = val

                # Update the first row with combined values
                first_id = ids_to_delete[0]
                cur.execute("""
                    UPDATE overtimes
                    SET rd = %s,
                        rd_ot = %s,
                        rd_nd = %s,
                        rd_nd_ot = %s
                    WHERE id = %s
                """, (combined["rd"], combined["rd_ot"], combined["rd_nd"], combined["rd_nd_ot"], first_id))

                # Delete all other duplicates
                for del_id in ids_to_delete[1:]:
                    cur.execute("DELETE FROM overtimes WHERE id = %s", (del_id,))
                
                logging.info(f"Merged RD entries into ID={first_id} on {record_date}")

            conn.commit()
            logging.info("All RD entries merged successfully.")

    except Exception as e:
        conn.rollback()
        logging.error(f"Failed to merge RD entries: {e}")
        raise


def log_security_db(conn, row, type, hours, biometric_imports_id, attendance_records_id):
    """
    Logs or updates security attendance details into the security_attendance database table.

    If a record with the same employee_management_id, record_date, earliest_time, and latest_time exists,
    it will UPDATE the matching column (hours_worked, ot, nd) instead of inserting a new row.
    """

    try:
        employee_name = str(row["employee_name"])
        record_date = str(row["record_date"]).split(" ")[0]
        earliest_time = str(row["earliest_time"])
        latest_time = str(row["latest_time"])

        # Get weekday from record_date
        weekday = pd.to_datetime(record_date).day_name()

        with conn.cursor() as cur:
            # --- Step 1: Get employee_management.id ---
            cur.execute("""
                SELECT id FROM employee_management
                WHERE employee_name = %s
                LIMIT 1;
            """, (employee_name,))
            result = cur.fetchone()
            if not result:
                logging.info(f"No employee found for {employee_name}. Skipping log.")
                return
            employee_id = result[0]

            # --- Step 2: Check if record already exists ---
            cur.execute("""
                SELECT id FROM security_attendance
                WHERE employee_management_id = %s
                AND record_date = %s
                AND earliest_time = %s
                AND latest_time = %s
                AND biometric_imports_id = %s
                LIMIT 1;
            """, (employee_id, record_date, earliest_time, latest_time, biometric_imports_id))
            existing = cur.fetchone()

            if existing:
                # --- Update existing record ---
                if type == "hours_worked":
                    update_query = """
                        UPDATE security_attendance
                        SET hours_worked = %s
                        WHERE employee_management_id = %s
                        AND record_date = %s
                        AND earliest_time = %s
                        AND latest_time = %s;
                    """
                elif type == "OT":
                    update_query = """
                        UPDATE security_attendance
                        SET ot = %s
                        WHERE employee_management_id = %s
                        AND record_date = %s
                        AND earliest_time = %s
                        AND latest_time = %s;
                    """
                elif type == "ND":
                    update_query = """
                        UPDATE security_attendance
                        SET nd = %s
                        WHERE employee_management_id = %s
                        AND record_date = %s
                        AND earliest_time = %s
                        AND latest_time = %s;
                    """
                else:
                    logging.info(f"Unknown type: {type}. No update performed.")
                    return

                cur.execute(update_query, (hours, employee_id, record_date, earliest_time, latest_time))
                conn.commit()
                logging.info(f"Updated {type} for {employee_name} ({weekday}, {record_date}).")

            else:
                # --- Insert new record ---
                if type == "hours_worked":
                    query = """
                        INSERT INTO security_attendance
                        (employee_management_id, record_date, weekday, earliest_time, latest_time, hours_worked, biometric_imports_id, attendance_records_id)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
                    """
                    values = (employee_id, record_date, weekday, earliest_time, latest_time, hours, biometric_imports_id, attendance_records_id)

                elif type == "OT":
                    query = """
                        INSERT INTO security_attendance
                        (employee_management_id, record_date, weekday, earliest_time, latest_time, ot, biometric_imports_id, attendance_records_id)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
                    """
                    values = (employee_id, record_date, weekday, earliest_time, latest_time, hours, biometric_imports_id, attendance_records_id)

                elif type == "ND":
                    query = """
                        INSERT INTO security_attendance
                        (employee_management_id, record_date, weekday, earliest_time, latest_time, nd, biometric_imports_id, attendance_records_id)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
                    """
                    values = (employee_id, record_date, weekday, earliest_time, latest_time, hours, biometric_imports_id, attendance_records_id)

                else:
                    logging.info(f"Unknown type: {type}. No insert performed.")
                    return

                cur.execute(query, values)
                conn.commit()
                logging.info(f"Inserted {type} record for {employee_name} ({weekday}, {record_date}).")

    except Exception as ex:
        logging.info(f"Error logging security DB for {row.get('employee_name', 'Unknown')}: {ex}")
        conn.rollback()


def calculate_hours_worked(df,data, biometric_imports_id):
    """Calculates hours worked, ORD-OT, RD, and Night Differential."""
    try:
        # Convert the time columns to timedelta
        df["earliest_time"] = pd.to_timedelta(df["earliest_time"], errors="coerce")
        df["latest_time"] = pd.to_timedelta(df["latest_time"], errors="coerce")
        # Initialize 'Ord-ND' with a default value of 0
        df["Ord-ND"] = 0
        df["Ord-ND-OT"] = 0
        df["RD-ND"] = 0
        df["RD-ND-OT"] = 0
        df["RegNDExcess"] = 0
        

        # Check if today is January 1, run the calculation for the year
        today = datetime.datetime.now()
        current_year = today.year
        if today.month == 1 and today.day == 1:
            calculate_total_non_workingdays(current_year, engine)

        # Get all non-working days from custom_dates table
        custom_dates_df = pd.read_sql("SELECT record_date, holiday_type FROM custom_dates", engine)
        # Filter by holiday type
        regular_holiday = custom_dates_df[custom_dates_df['holiday_type'] == "regular holiday"]['record_date'].astype(str).tolist()
        special_holiday = custom_dates_df[custom_dates_df['holiday_type'] == "non-working holiday"]['record_date'].astype(str).tolist()
        sundays = custom_dates_df[custom_dates_df['holiday_type'] == "Rest Day"]['record_date'].astype(str).tolist()
        non_working_days = custom_dates_df['record_date'].astype(str).tolist()

        #overtimes
        overtimes = pd.read_sql("SELECT type, last_name, first_name, record_date FROM overtimes", engine)
        

        def calculate_row_hours(row):
            try:
               
                # last_name   = row["last_name"].strip()
                # first_name  = row["first_name"].strip()
                record_date = str(row["record_date"]).split(" ")[0]

                for non_working_day in non_working_days:
                    if record_date == sundays:
                        return 0
                # check if row[leave] is true if return 0 since data is on attendance_record
                # --- Skip if marked as leave in attendance_records ---
                if row.get("leaves"):
                    logging.info(f"Leave marked for employee {row.get('employee_management_id')} on {record_date}. Skipping hours calculation.")
                    return 0
                
                
                
                # Validate earliest and latest_times
                if pd.isna(row["earliest_time"]) or pd.isna(row["latest_time"]):
                    # logging.info("nvalid earliest_time or latest_time. Hours calculated: 0")
                    return 0

                # Handle case where earliest_time and latest_time are the same
                if row["earliest_time"] == row["latest_time"]:
                    # logging.info("arliest Time and latest_time are the same. Hours calculated: 0")
                    return 0
                earliest_time = pd.to_timedelta(row["earliest_time"])
                latest_time = pd.to_timedelta(row["latest_time"])
               
                # commented 8/28:employee_name =  row["last_name"]+", "+row["first_name"]
                employee_name = str(row["employee_name"])


              
                #temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments", engine)
                temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)

                # Find matching schedule
                #logging.info(employee_name)
                #match = data[data["Name"] == employee_name]
                
                # --- Base schedule from employee_management ---
                schedule = None
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        SELECT schedule
                        FROM employee_management
                        WHERE employee_name = %s
                        LIMIT 1;
                        """,
                        (employee_name,),
                    )
                    sched_row = cur.fetchone()
                if sched_row and sched_row[0]:
                    schedule = sched_row[0]

               

                temp_match = temp_sched_pd[
                    (temp_sched_pd["employee_name"] == employee_name) &
                    (temp_sched_pd["record_date"] == record_date)
                ]

                if not temp_match.empty:
                    schedule = temp_match.iloc[0]["schedule"]
                    if isinstance(schedule, pd.Series):
                        schedule = schedule.iloc[0]
                else:
                    match = data[data["employee_name"] == employee_name]
                    if match.empty:
                        #return [0, 0, 0]
                        return 0
                    schedule = match.iloc[0]["schedule"]
                    if isinstance(schedule, pd.Series):
                        schedule = schedule.iloc[0]

                if schedule:
                    logging.info(f"schedule: {schedule}")

                    try:
                        # --- Special handling for SECURITY department ---
                        if str(row.get("department", "")).strip().lower() == "security":
                            # Determine which base schedule is closer to the earliest_time
                            seven_am = pd.to_timedelta("07:00:00")
                            seven_pm = pd.to_timedelta("19:00:00")

                            # compute difference in absolute hours
                            diff_to_7 = abs(earliest_time - seven_am)
                            diff_to_19 = abs(earliest_time - seven_pm)

                            # pick whichever is smaller → likely shift start
                            if diff_to_7 <= diff_to_19:
                                schedule = "7-19"
                                logging.info(f"Auto-detected DAY schedule (7-19) for security: {employee_name}")
                            else:
                                schedule = "19-7"
                                logging.info(f"Auto-detected NIGHT schedule (19-7) for security: {employee_name}")

                        # Split schedule like "19-7" → start=19, end=7
                        start_str, end_str = schedule.split("-")

                        # Normalize to two digits (e.g., 7 -> 07)
                        start_hour = int(start_str)
                        end_hour = int(end_str)

                        # Format required times as HH:MM:SS
                        start_required = f"{start_hour:02d}:00:00"
                        out_time_required = f"{end_hour:02d}:00:00"


                        # Build late cutoff = start + 15 minutes
                        late_cutoff = pd.to_timedelta(f"{start_hour:02d}:15:00")

                        # Build replacement = start + 1 hour
                        replace_hour = (start_hour + 1) % 24
                        replace_time = pd.to_timedelta(f"{replace_hour:02d}:00:00")

                        # Apply the rule dynamically
                        if earliest_time > late_cutoff:
                            earliest_time = replace_time
                            logging.info(f"Adjusted earliest_time: {earliest_time}")

                    except Exception as e:
                        logging.info(f"Invalid or unrecognized schedule format: {schedule} ({e})")
                # Assume: schedule already determined
                day_shift = schedule in ("7-16", "8-17", "7-19","6-15","9-15","10-18","10-16")
                night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")
                schedule_shift = "day shift"
                if day_shift:
                    schedule_shift = "day shift"
                elif night_shift:
                    schedule_shift = "night shift"
                else:
                    schedule_shift = None
                date_base = pd.to_datetime(record_date,errors="coerce")
                in_time = date_base + earliest_time
                late = False
                late_hours = late_minutes = 0
                morning_limit = date_base + pd.Timedelta("12:00:00")
                
                if date_base <= in_time < morning_limit and earliest_time > late_cutoff:
                    late = True
                    delta = earliest_time - start_required
                    late_hours   = delta.components.hours
                    late_minutes = delta.components.minutes

                     # Only bump if less than 1 hour late
                    if delta < pd.Timedelta(hours=1):
                        in_time = in_time.floor("h") + pd.Timedelta(hours=1)
                        #delta = in_time.time() - start_required  # recompute delta after bump
                        delta = in_time - (date_base + start_required)
                        
                    late = True
                    late_hours   = delta.components.hours
                    late_minutes = delta.components.minutes
               
            
                
                    
                
                # Calculate hours worked
                if pd.notna(earliest_time) and pd.notna(latest_time):
                    if earliest_time <= latest_time:
                        # Times are on the same day
                        hours = (latest_time - earliest_time).total_seconds() / 3600.0
                        # logging.info(f"imes are on the same day. Hours calculated: {hours}")
                    else:
                        # Times cross midnight
                        hours = (
                            (latest_time + pd.Timedelta(hours=24)) - earliest_time
                        ).total_seconds() / 3600.0
                        # logging.info(f"imes cross midnight. Hours calculated: {hours}")

                    # Subtract 1 hour for breaks (if applicable) and ensure non-negative hours    
                    adjusted_hours = max(hours - 1, 0)
                    if (schedule == "15-23" or schedule == "23-7" or schedule == "7-19" or schedule == "19-7" or schedule =="9-15"):
                        adjusted_hours = hours
                    logging.info(f"Adjusted hours: {adjusted_hours}")

                    # logging.info(f"djusted hours after subtracting 1: {adjusted_hours}")

                    # Cap hours to 8 if no employee record is found
                    # if not employee_record and adjusted_hours > 8:
                    #     adjusted_hours = 8
                        # logging.info(f"apped hours for non-employee record: {adjusted_hours}")

                    # If less than 8, return the rounded value using round()
                    if adjusted_hours < 8:
                        rounded_hours = round(adjusted_hours)
                        logging.info(f"Less than 8 hours: {rounded_hours}")
                        return rounded_hours

                    # Otherwise, round and return using round()
                    rounded_hours = round(adjusted_hours)
                    logging.info(rounded_hours)

                     
                    # if record_date in regular_holiday:
                    #     log_overtime_to_db(
                    #         conn,
                    #         row,
                    #         ord_ot=0,
                    #         rd_ot=0,
                    #         ord_nd=0,
                    #         ord_nd_ot=0,
                    #         rd_nd=0,
                    #         rd_nd_ot=0,
                    #         rd=0,
                    #         total_non_working_days_present=0,
                    #         late=late,
                    #         late_hours=late_hours,
                    #         late_minutes=late_minutes,
                    #         out_time_required=out_time_required,
                    #         type="LH",
                    #         schedule=schedule,
                    #         status="Pending",
                    #         biometric_imports_id=biometric_imports_id,attendance_records_id=row["id"], schedule_shift=schedule_shift,sh=0,sh_ot=0,sh_nd=0, lh=hours, lh_ot=0, lh_nd=0
                    #     )
                    #     return 0
                        
                    # elif record_date in special_holiday:
                    #     log_overtime_to_db(
                    #         conn,
                    #         row,
                    #         ord_ot=0,
                    #         rd_ot=0,
                    #         ord_nd=0,
                    #         ord_nd_ot=0,
                    #         rd_nd=0,
                    #         rd_nd_ot=0,
                    #         rd=hours,
                    #         total_non_working_days_present=0,
                    #         late=late,
                    #         late_hours=late_hours,
                    #         late_minutes=late_minutes,
                    #         out_time_required=out_time_required,
                    #         type="SH",
                    #         schedule=schedule,
                    #         status="Pending",
                    #         biometric_imports_id=biometric_imports_id,attendance_records_id=row["id"], schedule_shift=schedule_shift)
                    #     return 0

                    # # insert it to log security db if department is equal to security
                    # if row["department"].lower() == "security":
                    #     logging.info(f"hours worked:{employee_name}: {rounded_hours}")
                    #     log_security_db(conn, row, "hours_worked", rounded_hours, biometric_imports_id)
                        #return
                    return rounded_hours

                return 0
            except Exception as ex:
                logging.info(f"Error calculating row hours: {ex}")
                return 0   

        # Apply the helper function to the DataFrame
        df["Hours Worked"] = df.apply(calculate_row_hours, axis=1)
        logging.info(f"hours worked done")

        # Replace NaN or infinite values with 0
        df["Hours Worked"] = (
            df["Hours Worked"].replace([np.inf, -np.inf], np.nan).fillna(0)
        )
        # logging.info("est1")

        #logging.info("RD Flag")
        
        def autocalculate_ord(row):
            try:
               
                # 1) Identify date & skip non‐working days
                record_date = str(row["record_date"]).split(" ")[0]
                #logging.info(f"record date ord {type(record_date)}")

                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
                # convert MM/DD/YYYY string to YYYY-MM-DD on the fly
                
                #logging.info(f"rocessing record_date: {record_date}")  #  logging.info each record_date
                if record_date in cleaned_non_working_days:
                    
                    logging.info(f"ord skip record_date: {record_date}")
                    return [0, 0, 0]
                
                # --- Skip if marked as leave in attendance_records ---
                if row.get("leaves"):
                    logging.info(f"Leave marked for employee {row.get('employee_management_id')} on {record_date}. Skipping hours calculation.")
                    return [0, 0, 0]
                
                earliest_time = row["earliest_time"]  # Timedelta since midnight
                latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
                logging.info(f"type of earliest time{type(earliest_time)}")
                logging.info(f"type of latest time{type(latest_time)}")
                # earliest_time = earliest_time.iloc[0] if isinstance(earliest_time, pd.Series) else earliest_time
                # latest_time = latest_time.iloc[0] if isinstance(latest_time, pd.Series) else latest_time
                if earliest_time == latest_time:
                    return [0, 0, 0]

                # 2) Lookup schedule & determine late cutoff + required out time
                
                # last_name     = row["last_name"].strip()
                # first_name    = row["first_name"].strip()
                # ✅ Pull temp_sched table directly from PostgreSQL
                # temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments", engine)
                temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)

                #temp_sched_pd["employee_name"] = temp_sched_pd["last_name"].str.strip() + ", " + temp_sched_pd["first_name"].str.strip()
                #temp_sched_pd["record_date"] = temp_sched_pd["record_date"]  # normalise the column name
                
                # Build the combined name
                #employee_name = f"{last_name}, {first_name}"
                
                employee_name = str(row["employee_name"])


                # First look in temp schedule for that person/date
                temp_match = temp_sched_pd[
                    (temp_sched_pd["employee_name"] == employee_name) &
                    (temp_sched_pd["record_date"] == record_date)
                ]
               

                
                if not temp_match.empty:
                    schedule = temp_match.iloc[0]["schedule"]
                    if isinstance(schedule, pd.Series):
                        schedule = schedule.iloc[0]
                else:
                    match = data[data["employee_name"] == employee_name]
                    if match.empty:
                        return [0, 0, 0]
                    schedule = match.iloc[0]["schedule"]
                    if isinstance(schedule, pd.Series):
                        schedule = schedule.iloc[0]
                

                if schedule:
                    logging.info(f"schedule: {schedule}")

                    try:
                        # --- Special handling for SECURITY department ---
                        if str(row.get("department", "")).strip().lower() == "security":
                            # Determine which base schedule is closer to the earliest_time
                            seven_am = pd.to_timedelta("07:00:00")
                            seven_pm = pd.to_timedelta("19:00:00")

                            # compute difference in absolute hours
                            diff_to_7 = abs(earliest_time - seven_am)
                            diff_to_19 = abs(earliest_time - seven_pm)

                            # pick whichever is smaller → likely shift start
                            if diff_to_7 <= diff_to_19:
                                schedule = "7-19"
                                logging.info(f"Auto-detected DAY schedule (7-19) for security: {employee_name}")
                            else:
                                schedule = "19-7"
                                logging.info(f"Auto-detected NIGHT schedule (19-7) for security: {employee_name}")
                        # Split schedule like "19-7" → start=19, end=7
                        start_str, end_str = schedule.split("-")

                        # Normalize to two digits (e.g., 7 -> 07)
                        start_hour = int(start_str)
                        end_hour = int(end_str)

                        # Format required times as HH:MM:SS
                        start_required = f"{start_hour:02d}:00:00"
                        out_time_required = f"{end_hour:02d}:00:00"

                        # Build late cutoff = start + 15 minutes
                        late_cutoff = pd.to_timedelta(f"{start_hour:02d}:15:00")

                        # Build replacement = start + 1 hour
                        replace_hour = (start_hour + 1) % 24
                        replace_time = pd.to_timedelta(f"{replace_hour:02d}:00:00")

                        

                        # Apply the rule dynamically
                        if earliest_time > late_cutoff:
                            earliest_time = replace_time
                            logging.info(f"Adjusted earliest_time: {earliest_time}")

                    except Exception as e:
                        logging.info(f"Invalid or unrecognized schedule format: {schedule} ({e})")
                
                # 3) Detect late (but only if punch is before noon)
                #earliest_time = row["earliest_time"]  # Timedelta since midnight
                #date_base     = pd.to_datetime(record_date, format="%Y-%m-%d")
                #date_base = pd.to_datetime(record_date, errors="coerce")

                
                date_base = pd.to_datetime(record_date,errors="coerce")
                in_time = date_base + earliest_time
                late = False
                late_hours = late_minutes = 0
                morning_limit = date_base + pd.Timedelta("12:00:00")
                
                if date_base <= in_time < morning_limit and earliest_time > late_cutoff:
                    late = True
                    delta = earliest_time - start_required
                    late_hours   = delta.components.hours
                    late_minutes = delta.components.minutes

                     # Only bump if less than 1 hour late
                    if delta < pd.Timedelta(hours=1):
                        in_time = in_time.floor("h") + pd.Timedelta(hours=1)
                        #delta = in_time.time() - start_required  # recompute delta after bump
                        delta = in_time - (date_base + start_required)
                        
                    late = True
                    late_hours   = delta.components.hours
                    late_minutes = delta.components.minutes
                
                # 4) Compute out_time and fix overnight
                #out_time = date_base + row.get("latest_time", pd.Timedelta("00:00:00"))
                out_time = date_base + latest_time
                # logging.info(f"n {in_time}")
                # logging.info(f"ut {out_time}")
                if out_time <= in_time:
                    out_time += pd.Timedelta(days=1)
                if in_time == out_time:
                    return [0, 0, 0]

                # Assume: schedule already determined
                day_shift = schedule in ("7-16", "8-17", "7-19","6-15","9-15","10-18","10-16")
                night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")
                schedule_shift = "day shift"
                if day_shift:
                    schedule_shift = "day shift"
                elif night_shift:
                    schedule_shift = "night shift"
                else:
                    schedule_shift = None

                ord_nd    = pd.Timedelta(0)
                ord_ot    = pd.Timedelta(0)
                ord_nd_ot = pd.Timedelta(0)
                worked    = pd.Timedelta(0)

                nd_start   = pd.to_timedelta("22:00:00")
                nd_end     = pd.to_timedelta("06:00:00")
                base_hours = pd.to_timedelta("09:00:00")
                if schedule in ("15-23", "23-7","9-15"):
                    base_hours = pd.to_timedelta("08:00:00")
                

                ot_blocks = []  # list of (duration, is_nd)
                logging.info("123456")
                current = in_time
                while current < out_time:
                    next_hour = min(current + pd.Timedelta(hours=1), out_time)
                    block     = next_hour - current

                    # determine if this block is ND
                    tod    = current.time()
                    tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                    is_nd  = (tod_td >= nd_start) or (tod_td < nd_end)

                    if day_shift:
                        # day shift: normal rule (need to reach base hours first)
                        if worked < base_hours:
                            if is_nd:
                                # ND during base hours for day shift goes directly to ND-OT
                                ot_blocks.append((block, True))
                                # do not increase worked
                            else:
                                worked += block
                        else:
                            ot_blocks.append((block, is_nd))
                   
                    elif night_shift:
                        #logging.info(f"nNight shift detected at {current} | Block: {block} | Worked so far: {worked}")

                        # For no employee record, we still process all blocks but adjust ND calculation
                        if worked < base_hours:
                            remaining_base = base_hours - worked
                            #logging.info(f"emaining base hours: {remaining_base}")

                            # calculate actual ND portion inside this block
                            nd_block = pd.Timedelta(0)

                            # shift boundaries
                            shift_start = current
                            shift_end = current + block   # <-- convert Timedelta into Timestamp

                            # ND window boundaries: 22:00–06:00 (spans midnight)
                            # Use the same approach as other sections - check if current time is ND
                            tod = current.time()
                            tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                            nd_start_td = pd.to_timedelta("22:00:00")
                            nd_end_td = pd.to_timedelta("06:00:00")
                            is_nd = (tod_td >= nd_start_td) or (tod_td < nd_end_td)
                            
                            # # If no employee record, only count ND from schedule start time
                            # if not employee_record:
                            #     schedule_start_hour = schedule.split("-")[0]
                            #     schedule_start_td = pd.to_timedelta(f"{schedule_start_hour}:00:00")
                            #     # For night shifts, handle midnight crossover properly
                            #     if schedule_start_hour in ["18", "19", "20", "21", "22", "23"]:
                            #         # Night shift: only count ND if current time is after schedule start
                            #         # Handle midnight crossover: times 00:00-06:00 are considered after 23:00
                            #         if tod_td >= schedule_start_td or tod_td < pd.to_timedelta("06:00:00"):
                            #             pass  # Keep is_nd as is
                            #         else:
                            #             is_nd = False
                            #     else:
                            #         # Day shift: normal comparison
                            #         is_nd = is_nd and (tod_td >= schedule_start_td)
                            
                            # If this block is ND, the entire block is ND
                            if is_nd:
                                nd_block = block
                            else:
                                nd_block = pd.Timedelta(0)

                            # logging.info(f"aw ND block: {nd_block}")
                            # logging.info(f"urrent time: {current}, Block size: {block}, Is ND: {is_nd}")

                            # cap ND to remaining base
                            nd_block = min(nd_block, remaining_base)
                            worked_block = min(block, remaining_base)
                            worked += worked_block

                            # logging.info(f"orked block (base): {worked_block}, ND portion: {nd_block}")
                            # logging.info(f"otal ND so far: {ord_nd}")

                            # split base into ND and non-ND
                            ord_nd += nd_block
                            non_nd_base = worked_block - nd_block
                            if non_nd_base > pd.Timedelta(0):
                                pass
                                #logging.info(f"on-ND base portion: {non_nd_base}")
                                

                            # remainder becomes OT
                            second_part = block - worked_block
                            if second_part > pd.Timedelta(0):
                                ot_blocks.append((second_part, is_nd))
                                # #logging.info(f"emainder (possible OT): {second_part}")
                                # if employee_record:
                                #     ot_blocks.append((second_part, is_nd))
                                #     #logging.info(f"  Added OT block: {second_part}, ND={is_nd}")
                                # else:
                                #     pass
                                #     #logging.info("  Skipping OT (not in employee record)")
                        else:
                            #logging.info(f"ase hours already met. Entire block considered OT: {block}")
                            ot_blocks.append((block, is_nd))
                            # if employee_record:
                            #     ot_blocks.append((block, is_nd))
                            #     #logging.info(f"  Added OT block: {block}, ND={is_nd}")
                            # else:
                            #     #logging.info("  Skipping OT (not in employee record)")
                            #     pass

                    current = next_hour # mode one space to left



                   
                    # --- OT Handling ---
                    ot_total = sum((b for b, _ in ot_blocks), pd.Timedelta(0))
                    logging.info(f"In Total OT accumulated: {ot_total}")

                    if ot_total >= pd.Timedelta(hours=1):
                        remaining_first_hour = pd.Timedelta(hours=1)

                        for block, is_nd in ot_blocks:
                            logging.info(f"Processing OT block: {block}, ND={is_nd}")

                            # take from first OT hour
                            if remaining_first_hour > pd.Timedelta(0):
                                take = min(block, remaining_first_hour)
                                if is_nd:
                                    ord_nd_ot += take
                                    logging.info(f"  Counted ND OT (first hour): {take}")
                                    logging.info(f"  Total ND OT so far: {ord_nd_ot}")
                                else:
                                    ord_ot += take
                                    # logging.info(f"  Counted OT (first hour): {take}")
                                remaining_first_hour -= take
                                block -= take

                            # after first hour: only full ≥30min chunks count
                            full_chunks = block // pd.Timedelta(minutes=30)
                            if full_chunks > 0:
                                take = full_chunks * pd.Timedelta(minutes=30)
                                if is_nd:
                                    ord_nd_ot += take
                                    logging.info(f"  Counted ND OT chunks: {take}")
                                    logging.info(f"  Total ND OT so far: {ord_nd_ot}")
                                else:
                                    ord_ot += take
                                    logging.info(f"  Counted OT chunks: {take}")
                            else:
                                if block > pd.Timedelta(0):
                                    pass
                                    logging.info(f"  Ignored leftover OT under 30m: {block}")
                    else:
                        pass
                        #logging.info("otal OT less than 1h → ignored")
             
                logging.info(f"OT summary for {employee_name} on {record_date}: ord_ot={ord_ot}, ord_nd={ord_nd}, ord_nd_ot={ord_nd_ot}")
                # logging.info(f"DEBUG final totals -> ord_ot: {ord_ot}, ord_nd: {ord_nd}, ord_nd_ot: {ord_nd_ot}")
                if str(schedule).strip() == "15-24":
                    logging.info(f"ORD schedule Mark 15-24")

                    # Ensure latest_time is after earliest_time
                    if latest_time <= earliest_time:
                        latest_time += pd.Timedelta(days=1)

                    nd_start = pd.to_timedelta("22:00:00")
                    nd_end   = pd.to_timedelta("06:00:00")  # next day 06:00

                    ord_nd = pd.Timedelta(0)
                    ord_nd_ot = pd.Timedelta(0)
                    ord_ot = pd.Timedelta(0)

                    # --- Calculate total worked time ---
                    total_worked = latest_time - earliest_time

                    # --- Calculate ND (22:00–24:00) ---
                    nd_overlap_1 = max(pd.Timedelta(0), 
                                    min(latest_time, pd.to_timedelta("24:00:00")) - 
                                    max(earliest_time, nd_start))
                    ord_nd += nd_overlap_1

                    # --- Calculate ND past midnight (00:00–06:00) ---
                    nd_overlap_2 = max(pd.Timedelta(0),
                                    min(latest_time - pd.Timedelta(days=1), nd_end) - pd.Timedelta(0))

                    if nd_overlap_2 > pd.Timedelta(0):
                        if nd_overlap_2 >= pd.Timedelta(hours=1):
                            remaining_first_hour = pd.Timedelta(hours=1)
                            take = min(nd_overlap_2, remaining_first_hour)
                            ord_nd_ot += take
                            nd_overlap_2 -= take

                            # Count remaining in ≥30 min chunks
                            full_chunks = nd_overlap_2 // pd.Timedelta(minutes=30)
                            if full_chunks > 0:
                                ord_nd_ot += full_chunks * pd.Timedelta(minutes=30)
                            # leftover < 30 min ignored

                    # --- Apply OT validation like 7-16 schedule ---
                    # Scheduled: 9 hours (15 → 24)
                    base_hours = pd.Timedelta(hours=9)
                    excess_time = max(pd.Timedelta(0), total_worked - base_hours)

                    if excess_time > pd.Timedelta(0):
                        remaining_excess = excess_time

                        # First hour counts as OT
                        first_hour = min(remaining_excess, pd.Timedelta(hours=1))
                        if latest_time >= nd_start or latest_time < nd_end:
                            ord_nd_ot += first_hour
                        else:
                            ord_ot += first_hour
                        remaining_excess -= first_hour

                        # Remaining excess in ≥30 min chunks
                        if remaining_excess >= pd.Timedelta(minutes=30):
                            full_chunks = remaining_excess // pd.Timedelta(minutes=30)
                            chunk_time = full_chunks * pd.Timedelta(minutes=30)
                            if latest_time >= nd_start or latest_time < nd_end:
                                ord_nd_ot += chunk_time
                            else:
                                ord_ot += chunk_time
                            # leftover < 30 min ignored

                    # --- Validation per OT type ---
                    def validate_and_floor(t):
                        # 1) If less than 1 hour → return 0
                        if t < pd.Timedelta(hours=1):
                            return pd.Timedelta(0)
                        # 2) Floor to nearest 30 minutes
                        minutes = t.total_seconds() // 60
                        return pd.Timedelta(minutes=(minutes // 30) * 30)

                    ord_nd    = validate_and_floor(ord_nd)
                    ord_nd_ot = validate_and_floor(ord_nd_ot)
                    ord_ot    = validate_and_floor(ord_ot)

                    logging.info(f"15-24 Final OT: ord_ot={ord_ot}, ord_nd_ot={ord_nd_ot}, ord_nd={ord_nd}")
                #print(11111213123)
                if day_shift:
                    #print(11)
                    # Convert schedule to timedelta
                    schedule_start, schedule_end = map(int, schedule.split("-"))
                    scheduled_start = pd.Timedelta(hours=schedule_start)
                    scheduled_end = pd.Timedelta(hours=schedule_end)

                    # Adjust if latest_time < earliest_time (crossing midnight)
                    if latest_time < earliest_time:
                        latest_time += pd.Timedelta(days=1)

                    # Total worked
                    total_worked = latest_time - earliest_time

                    # Base hours = scheduled hours
                    base_hours = scheduled_end - scheduled_start

                    # Excess hours = total worked - base hours
                    excess_time = max(pd.Timedelta(0), total_worked - base_hours)

                    # ND OT window
                    nd_start = pd.Timedelta(hours=22)
                    nd_end   = pd.Timedelta(hours=6)

                    # Default
                    ord_ot = pd.Timedelta(0)
                    ord_nd_ot = pd.Timedelta(0)
                    ord_nd = pd.Timedelta(0)

                    if excess_time > pd.Timedelta(0):
                        # Split excess_time into OT blocks for validation
                        remaining_excess = excess_time

                        # First hour counts as OT
                        first_hour = min(remaining_excess, pd.Timedelta(hours=1))
                        if latest_time >= nd_start or latest_time < nd_end:
                            ord_nd_ot += first_hour
                        else:
                            ord_ot += first_hour
                        remaining_excess -= first_hour

                        # Remaining excess in ≥30 min chunks
                        if remaining_excess >= pd.Timedelta(minutes=30):
                            full_chunks = remaining_excess // pd.Timedelta(minutes=30)
                            chunk_time = full_chunks * pd.Timedelta(minutes=30)
                            if latest_time >= nd_start or latest_time < nd_end:
                                ord_nd_ot += chunk_time
                            else:
                                ord_ot += chunk_time
                            # leftover <30 min ignored

                    logging.info(f"{schedule} OT: ord_ot={ord_ot}, ord_nd_ot={ord_nd_ot}")

                latest_time_db = latest_time if isinstance(latest_time, str) else str(latest_time)
                if latest_time_db == "0 days 00:00:00":
                    latest_time = "00:00:00"
                logging.info(
                    f"ord_ot={ord_ot.total_seconds()}, "
                    f"ord_nd={ord_nd.total_seconds()}, "
                    f"ord_nd_ot={ord_nd_ot.total_seconds()}, "
                    f"condition={(ord_ot.total_seconds() <= 0 and ord_nd.total_seconds() <= 0 and ord_nd_ot.total_seconds() <= 0)}"
                )

                if row["department"].lower() == "security":
                    # Define time thresholds
                    t_7am = pd.Timedelta(hours=7)
                    t_715am = pd.Timedelta(hours=7, minutes=15)
                    t_7pm = pd.Timedelta(hours=19)
                    t_715pm = pd.Timedelta(hours=19, minutes=15)
                    t_7am_next = pd.Timedelta(hours=31)  # 07:00 next day

                    earliest_time = row["earliest_time"]
                    latest_time = row.get("latest_time", pd.Timedelta("00:00:00"))

                    # Determine which shift is closer to the in time (7 or 19)
                    diff_7am = abs(earliest_time - t_7am)
                    diff_7pm = abs(earliest_time - t_7pm)

                    # Initialize
                    ord_ot_val = 0.0
                    ord_nd_val = 0.0
                    ord_nd_ot_val = 0.0

                    if diff_7am <= diff_7pm:
                        # --- Day shift (7–19) ---
                        if earliest_time <= t_715am and latest_time >= t_7pm:
                            # Within expected range → fixed OT
                            ord_ot_val = 4.0
                            logging.info(f"Security (day shift) fixed OT = {ord_ot_val}")
                        else:
                            # Compute actual worked hours
                            worked_hours = (latest_time - earliest_time).total_seconds() / 3600
                            ord_ot_val = max(0, round(worked_hours - 8, 2))
                            logging.info(f"Security (day shift manual) worked={worked_hours:.2f} hrs, OT={ord_ot_val}")
                    else:
                        # --- Night shift (19–07) ---
                        # If latest_time is "earlier" than earliest_time, it crossed midnight
                        if latest_time < earliest_time:
                            latest_time += pd.Timedelta(days=1)

                        # define references for 7 PM and 7 AM next day
                        t_7pm = pd.to_timedelta("19:00:00")
                        t_7am_next = pd.to_timedelta("07:00:00") + pd.Timedelta(days=1)

                        if earliest_time <= t_7pm and latest_time >= t_7am_next:
                            ord_nd_ot_val = 4.0
                            logging.info(f"Security (night shift) fixed ND OT = {ord_nd_ot_val}")
                        else:
                            worked_hours = (latest_time - earliest_time).total_seconds() / 3600
                            ord_nd_ot_val = max(0, round(worked_hours - 8, 2))
                            logging.info(f"Security (night shift manual) worked={worked_hours:.2f} hrs, ND OT={ord_nd_ot_val}")

                    # # --- Log to both DBs ---
                    log_security_db(conn, row, "OT", ord_ot_val, biometric_imports_id)
                    logging.info(f"test nd {ord_nd_val} nd_ot{ord_nd_ot_val}")
                    log_security_db(conn, row, "ND", ord_nd_val + ord_nd_ot_val, biometric_imports_id)

                    log_overtime_to_db(
                        conn,
                        row,
                        ord_ot=ord_ot_val,
                        rd_ot=0,
                        ord_nd=ord_nd_val,
                        ord_nd_ot=ord_nd_ot_val,
                        rd_nd=0,
                        rd_nd_ot=0,
                        rd=0,
                        total_non_working_days_present=0,
                        late=late,
                        late_hours=late_hours,
                        late_minutes=late_minutes,
                        out_time_required=out_time_required,
                        type="ORD",
                        schedule=schedule,
                        status="Pending",
                        biometric_imports_id=biometric_imports_id, attendance_records_id=row["id"], schedule_shift=schedule_shift, update_target="ord"
                    )

                    # # Do NOT return any values for security
                    return [0,0,0]
                else:
                    # Non-security employees
                    if ord_ot.total_seconds() != 0 or ord_nd.total_seconds() != 0 or ord_nd_ot.total_seconds() != 0:
                        log_overtime_to_db(
                            conn,
                            row,
                            ord_ot=round(ord_ot.total_seconds() / 3600, 2),
                            rd_ot=0,
                            ord_nd=round(ord_nd.total_seconds() / 3600, 2),
                            ord_nd_ot=round(ord_nd_ot.total_seconds() / 3600, 2),
                            rd_nd=0,
                            rd_nd_ot=0,
                            rd=0,
                            total_non_working_days_present=0,
                            late=late,
                            late_hours=late_hours,
                            late_minutes=late_minutes,
                            out_time_required=out_time_required,
                            type="ORD",
                            schedule=schedule,
                            status="Pending",
                            biometric_imports_id=biometric_imports_id,attendance_records_id=row["id"], schedule_shift=schedule_shift, update_target="ord"
                    )
                # logging.info("1234666")
                #  return values
                logging.info(f"2nd OT summary for {employee_name} on {record_date}: ord_ot={ord_ot}, ord_nd={ord_nd}, ord_nd_ot={ord_nd_ot}")
                try:
                        
                        ord_ot_sec = ord_ot.total_seconds() if isinstance(ord_ot, pd.Timedelta) else 0.0
                        ord_nd_sec = ord_nd.total_seconds() if isinstance(ord_nd, pd.Timedelta) else 0.0
                        ord_nd_ot_sec = ord_nd_ot.total_seconds() if isinstance(ord_nd_ot, pd.Timedelta) else 0.0
                        
                        return [
                            round(ord_ot_sec / 3600, 2),
                            round(ord_nd_sec / 3600, 2),
                            round(ord_nd_ot_sec / 3600, 2),
                        ]
                except Exception as conv_ex:
                    logging.error(f"Error converting RD OT return values to seconds: {conv_ex}")
                    return [0, 0, 0]
                return [
                    round(ord_ot.total_seconds() / 3600, 2),
                    round(ord_nd.total_seconds() / 3600, 2),
                    round(ord_nd_ot.total_seconds() / 3600, 2),
                ]

            except Exception as ex:
                logging.info(f"Error auto-calculating ORD: {ex}")
                return [0, 0, 0]


        #logging.info("D OT Flag")
        def autocalculate_rd_overtime(row):
            try:
                
                
                # ✅ Pull temp_sched table directly from PostgreSQL
                #temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments", engine)
                temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)

                #temp_sched_pd["employee_name"] = temp_sched_pd["last_name"].str.strip() + ", " + temp_sched_pd["first_name"].str.strip()
                #temp_sched_pd["record_date"] = temp_sched_pd["record_date"]  # normalise the column name
                record_date = str(row["record_date"]).split(" ")[0]

                # --- Skip if marked as leave in attendance_records ---
                if row.get("leaves"):
                    logging.info(f"Leave marked for employee {row.get('employee_management_id')} on {record_date}. Skipping hours calculation.")
                    return [0, 0, 0]
                
                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
                if record_date not in cleaned_non_working_days:
                    return [0, 0, 0]
                earliest_time = row["earliest_time"]  # Timedelta since midnight
                latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
                if earliest_time == latest_time:
                    return [0, 0, 0]
                
                #logging.info(33)
                # 2) Build actual in/out datetimes from the row’s punches
                in_td   = row["earliest_time"]
                out_td  = row.get("latest_time", pd.to_timedelta("00:00:00"))
                date_base = pd.to_datetime(record_date,errors="coerce")
                in_time   = date_base + in_td
                out_time  = date_base + out_td

                # 3) Validate & handle cross‐midnight
                if in_time == out_time:
                    return [0, 0, 0]
                if out_time <= in_time:
                    out_time += pd.Timedelta(days=1)
                # Build the combined name
                #employee_name = f"{last_name}, {first_name}"
                employee_name = str(row["employee_name"])


                # First look in temp schedule for that person/date
                temp_match = temp_sched_pd[
                    (temp_sched_pd["employee_name"] == employee_name) &
                    (temp_sched_pd["record_date"] == record_date)
                ]
                #logging.info(44)
                if not temp_match.empty:
                    schedule = temp_match.iloc[0]["schedule"]
                    if isinstance(schedule, pd.Series):
                        schedule = schedule.iloc[0]
                else:
                    match = data[data["employee_name"] == employee_name]
                    if match.empty:
                        return [0, 0, 0]
                    schedule = match.iloc[0]["schedule"]
                    if isinstance(schedule, pd.Series):
                        schedule = schedule.iloc[0]
                # 4) Determine late‐cutoff (for morning rounding)
                # late_cutoff = pd.to_timedelta("07:15:00") if schedule == "7-16" else pd.to_timedelta("08:15:00")
                if schedule:
                    logging.info(f"schedule: {schedule}")

                    try:
                        # --- Special handling for SECURITY department ---
                        if str(row.get("department", "")).strip().lower() == "security":
                            # Determine which base schedule is closer to the earliest_time
                            seven_am = pd.to_timedelta("07:00:00")
                            seven_pm = pd.to_timedelta("19:00:00")

                            # compute difference in absolute hours
                            diff_to_7 = abs(earliest_time - seven_am)
                            diff_to_19 = abs(earliest_time - seven_pm)

                            # pick whichever is smaller → likely shift start
                            if diff_to_7 <= diff_to_19:
                                schedule = "7-19"
                                logging.info(f"Auto-detected DAY schedule (7-19) for security: {employee_name}")
                            else:
                                schedule = "19-7"
                                logging.info(f"Auto-detected NIGHT schedule (19-7) for security: {employee_name}")
                        # Split schedule like "19-7" → start=19, end=7
                        start_str, end_str = schedule.split("-")

                        # Normalize to two digits (e.g., 7 -> 07)
                        start_hour = int(start_str)
                        end_hour = int(end_str)

                        # Format required times as HH:MM:SS
                        start_required = f"{start_hour:02d}:00:00"
                        out_time_required = f"{end_hour:02d}:00:00"

                        # Build late cutoff = start + 15 minutes
                        late_cutoff = pd.to_timedelta(f"{start_hour:02d}:15:00")

                        # Build replacement = start + 1 hour
                        replace_hour = (start_hour + 1) % 24
                        replace_time = pd.to_timedelta(f"{replace_hour:02d}:00:00")

                        

                        # Apply the rule dynamically
                        if earliest_time > late_cutoff:
                            earliest_time = replace_time
                            logging.info(f"Adjusted earliest_time: {earliest_time}")

                    except Exception as e:
                        logging.info(f"Invalid or unrecognized schedule format: {schedule} ({e})")
                
                #logging.info(55)

                # date_base = pd.to_datetime(record_date,errors="coerce")
                # in_time = date_base + earliest_time
                late = False
                late_hours = late_minutes = 0
                morning_limit = date_base + pd.Timedelta("12:00:00")
                
                if date_base <= in_time < morning_limit and earliest_time > late_cutoff:
                    late = True
                    delta = earliest_time - start_required
                    late_hours   = delta.components.hours
                    late_minutes = delta.components.minutes

                     # Only bump if less than 1 hour late
                    if delta < pd.Timedelta(hours=1):
                        in_time = in_time.floor("h") + pd.Timedelta(hours=1)
                        #delta = in_time.time() - start_required  # recompute delta after bump
                        delta = in_time - (date_base + start_required)
                        
                    late = True
                    late_hours   = delta.components.hours
                    late_minutes = delta.components.minutes

               

                # Assume: schedule already determined
                day_shift = schedule in ("7-16", "8-17", "7-19","6-15","9-15","10-18","10-16")
                night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")
                schedule_shift = "day shift"
                if day_shift:
                    schedule_shift = "day shift"
                elif night_shift:
                    schedule_shift = "night shift"
                else:
                    schedule_shift = None
                
                # 4) Prepare counters and thresholds
                rd_nd     = pd.Timedelta(0)
                rd_ot     = pd.Timedelta(0)
                rd_nd_ot  = pd.Timedelta(0)
                worked    = pd.Timedelta(0)

                nd_start   = pd.to_timedelta("22:00:00")
                nd_end     = pd.to_timedelta("06:00:00")
                base_hours = pd.to_timedelta("09:00:00")
                if schedule in ("15-23", "23-7","9-15"):
                    base_hours = pd.to_timedelta("08:00:00")
                

                ot_blocks = []  # list of (duration, is_nd)

                current = in_time
                while current < out_time:
                    next_hour = min(current + pd.Timedelta(hours=1), out_time)
                    block     = next_hour - current

                    # determine if this block is ND
                    tod    = current.time()
                    tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                    is_nd  = (tod_td >= nd_start) or (tod_td < nd_end)

                    if day_shift:
                        # day shift: normal rule (need to reach base hours first)
                        if worked < base_hours:
                            if is_nd:
                                # ND during base hours for day shift goes directly to ND-OT
                                ot_blocks.append((block, True))
                                # do not increase worked
                            else:
                                worked += block
                        else:
                            ot_blocks.append((block, is_nd))
                    elif night_shift:
                        #logging.info(f"nNight shift detected at {current} | Block: {block} | Worked so far: {worked}")

                        # For no employee record, we still process all blocks but adjust ND calculation

                        if worked < base_hours:
                            remaining_base = base_hours - worked
                            #logging.info(f"emaining base hours: {remaining_base}")

                            # calculate actual ND portion inside this block
                            nd_block = pd.Timedelta(0)

                            # shift boundaries
                            shift_start = current
                            shift_end = current + block   # <-- convert Timedelta into Timestamp

                            # ND window boundaries: 22:00–06:00 (spans midnight)
                            # Use the same approach as other sections - check if current time is ND
                            tod = current.time()
                            tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                            nd_start_td = pd.to_timedelta("22:00:00")
                            nd_end_td = pd.to_timedelta("06:00:00")
                            is_nd = (tod_td >= nd_start_td) or (tod_td < nd_end_td)
                            
                            # If no employee record, only count ND from schedule start time
                            # if not employee_record:
                            #     schedule_start_hour = schedule.split("-")[0]
                            #     schedule_start_td = pd.to_timedelta(f"{schedule_start_hour}:00:00")
                            #     # For night shifts, handle midnight crossover properly
                            #     if schedule_start_hour in ["18", "19", "20", "21", "22", "23"]:
                            #         # Night shift: only count ND if current time is after schedule start
                            #         # Handle midnight crossover: times 00:00-06:00 are considered after 23:00
                            #         if tod_td >= schedule_start_td or tod_td < pd.to_timedelta("06:00:00"):
                            #             pass  # Keep is_nd as is
                            #         else:
                            #             is_nd = False
                            #     else:
                            #         # Day shift: normal comparison
                            #         is_nd = is_nd and (tod_td >= schedule_start_td)
                            
                            # If this block is ND, the entire block is ND
                            if is_nd:
                                nd_block = block
                            else:
                                nd_block = pd.Timedelta(0)

                            # logging.info(f"aw ND block: {nd_block}")
                            # logging.info(f"urrent time: {current}, Block size: {block}, Is ND: {is_nd}")

                            # cap ND to remaining base
                            nd_block = min(nd_block, remaining_base)
                            worked_block = min(block, remaining_base)
                            worked += worked_block

                            # logging.info(f"orked block (base): {worked_block}, ND portion: {nd_block}")
                            # logging.info(f"otal ND so far: {ord_nd}")

                            # split base into ND and non-ND
                            rd_nd += nd_block
                            non_nd_base = worked_block - nd_block
                            if non_nd_base > pd.Timedelta(0):
                                pass
                                #logging.info(f"on-ND base portion: {non_nd_base}")

                            # remainder becomes OT
                            second_part = block - worked_block
                            if second_part > pd.Timedelta(0):
                                # logging.info(f"emainder (possible OT): {second_part}")
                                ot_blocks.append((second_part, is_nd))
                                # if employee_record:
                                #     ot_blocks.append((second_part, is_nd))
                                #     #logging.info(f"  Added OT block: {second_part}, ND={is_nd}")
                                # else:
                                #     pass
                                #     #logging.info("  Skipping OT (not in employee record)")
                        else:
                            #logging.info(f"ase hours already met. Entire block considered OT: {block}")
                            ot_blocks.append((block, is_nd))
                            # if employee_record:
                            #     ot_blocks.append((block, is_nd))
                            #     # logging.info(f"  Added OT block: {block}, ND={is_nd}")
                            # else:
                            #     pass
                            #     #logging.info("  Skipping OT (not in employee record)")

                    current = next_hour

                    # --- OT Handling ---
                    ot_total = sum((b for b, _ in ot_blocks), pd.Timedelta(0))
                    #logging.info(f"nTotal OT accumulated: {ot_total}")

                    if ot_total >= pd.Timedelta(hours=1):
                        remaining_first_hour = pd.Timedelta(hours=1)

                        for block, is_nd in ot_blocks:
                            # logging.info(f"rocessing OT block: {block}, ND={is_nd}")

                            # take from first OT hour
                            if remaining_first_hour > pd.Timedelta(0):
                                take = min(block, remaining_first_hour)
                                if is_nd:
                                    rd_nd_ot += take
                                    # logging.info(f"  Counted ND OT (first hour): {take}")
                                    # logging.info(f"  Total ND OT so far: {ord_nd_ot}")
                                else:
                                    rd_ot += take
                                    #logging.info(f"  Counted OT (first hour): {take}")
                                remaining_first_hour -= take
                                block -= take

                            # after first hour: only full ≥30min chunks count
                            full_chunks = block // pd.Timedelta(minutes=30)
                            if full_chunks > 0:
                                take = full_chunks * pd.Timedelta(minutes=30)
                                if is_nd:
                                    rd_nd_ot += take
                                    # logging.info(f"  Counted ND OT chunks: {take}")
                                    # logging.info(f"  Total ND OT so far: {ord_nd_ot}")
                                else:
                                    rd_ot += take
                                    #logging.info(f"  Counted OT chunks: {take}")
                            else:
                                if block > pd.Timedelta(0):
                                    pass
                                    #logging.info(f"  Ignored leftover OT under 30m: {block}")
                    else:
                        pass
                        #logging.info("otal OT less than 1h → ignored")


               
                # if 23-8 minus 1 hr for lunch in rd_nd
                if schedule.strip() in ["23-8"]:
                    rd_nd = rd_nd - pd.Timedelta(hours=1)
                    #logging.info("fter",rd_nd)
                    
    

                
                # logging.info(f"RD OT DEBUG] {employee_name} | IN: {in_time} | OUT: {out_time} | RD ND {rd_nd} RD OT {rd_ot} RD ND OT {rd_nd_ot}")
                # --- Special handling for 15-24 shift ---
                if str(schedule).strip() == "15-24":
                        logging.info(f"RD schedule Mark 15-24")

                        # Ensure latest_time is after earliest_time
                        if latest_time <= earliest_time:
                            latest_time += pd.Timedelta(days=1)

                        nd_start = pd.to_timedelta("22:00:00")
                        nd_end   = pd.to_timedelta("06:00:00")  # next day 06:00

                        rd_nd = pd.Timedelta(0)
                        rd_nd_ot = pd.Timedelta(0)
                        rd_ot = pd.Timedelta(0)

                        # --- Calculate total worked time ---
                        total_worked = latest_time - earliest_time

                        # --- Calculate ND (22:00–24:00) ---
                        nd_overlap_1 = max(pd.Timedelta(0),
                                        min(latest_time, pd.to_timedelta("24:00:00")) - max(earliest_time, nd_start))
                        rd_nd += nd_overlap_1

                        # --- Calculate ND past midnight (00:00–06:00) ---
                        nd_overlap_2 = max(pd.Timedelta(0),
                                        min(latest_time - pd.Timedelta(days=1), nd_end) - pd.Timedelta(0))

                        if nd_overlap_2 > pd.Timedelta(0):
                            if nd_overlap_2 >= pd.Timedelta(hours=1):
                                remaining_first_hour = pd.Timedelta(hours=1)
                                take = min(nd_overlap_2, remaining_first_hour)
                                rd_nd_ot += take
                                nd_overlap_2 -= take

                                # Count remaining in ≥30 min chunks
                                full_chunks = nd_overlap_2 // pd.Timedelta(minutes=30)
                                if full_chunks > 0:
                                    rd_nd_ot += full_chunks * pd.Timedelta(minutes=30)
                                # leftover <30 min ignored

                        # --- Add non-ND time to ORD OT if total > 8 hrs ---
                        if total_worked > pd.Timedelta(hours=8):
                            # Non-ND = total - ND parts
                            non_nd_time = total_worked - (rd_nd + rd_nd_ot)
                            if non_nd_time > pd.Timedelta(0):
                                rd_ot += non_nd_time

                        logging.info(f"rd_nd={rd_nd}, rd_nd_ot={rd_nd_ot}, ord_ot={rd_ot}")

                elif str(schedule).strip() == "23-8":
                    """23-8 RD: 6 hrs RD_ND, OT only if work goes past 08:00.Late/undertime reduces RD_ND."""
                    logging.info("RD schedule Mark 23-8")

                    # Ensure latest_time is after earliest_time
                    if latest_time <= earliest_time:
                        latest_time += pd.Timedelta(days=1)

                    # Baseline
                    base_rd_nd = pd.Timedelta(hours=6)
                    rd_nd = base_rd_nd
                    rd_ot = pd.Timedelta(0)

                    # Total worked
                    total_worked = latest_time - earliest_time

                    # Late / undertime
                    if total_worked < base_rd_nd:
                        rd_nd = total_worked  # reduce RD_ND if worked < 6h
                        rd_ot = pd.Timedelta(0)
                    else:
                        # RD_ND full 6h
                        rd_nd = base_rd_nd

                        # OT = everything beyond 08:00 (not beyond 6+2)
                        shift_end = earliest_time.normalize() + pd.Timedelta(days=1) + pd.Timedelta(hours=8)  # 08:00 next day
                        if latest_time > shift_end:
                            rd_ot = latest_time - shift_end
                        else:
                            rd_ot = pd.Timedelta(0)
                elif str(schedule).strip() == "23-7":
                    """23-7 RD: 6 hrs RD_ND, OT only if work goes past 08:00.Late/undertime reduces RD_ND."""
                    logging.info("RD schedule Mark 23-7")

                    # Ensure latest_time is after earliest_time
                    if latest_time <= earliest_time:
                        latest_time += pd.Timedelta(days=1)

                    # Baseline
                    base_rd_nd = pd.Timedelta(hours=6)
                    rd_nd = base_rd_nd
                    rd_ot = pd.Timedelta(0)

                    # Total worked
                    total_worked = latest_time - earliest_time

                    # Late / undertime
                    if total_worked < base_rd_nd:
                        rd_nd = total_worked  # reduce RD_ND if worked < 6h
                        rd_ot = pd.Timedelta(0)
                    else:
                        # RD_ND full 6h
                        rd_nd = base_rd_nd

                        # OT = everything beyond 08:00 (not beyond 6+2)
                        shift_end = earliest_time.normalize() + pd.Timedelta(days=1) + pd.Timedelta(hours=7)  # 08:00 next day
                        if latest_time > shift_end:
                            rd_ot = latest_time - shift_end
                        else:
                            rd_ot = pd.Timedelta(0)
                
                if day_shift:
                    # print(11)
                    # Convert schedule to timedelta
                    schedule_start, schedule_end = map(int, schedule.split("-"))
                    scheduled_start = pd.Timedelta(hours=schedule_start)
                    scheduled_end = pd.Timedelta(hours=schedule_end)

                    # Adjust if latest_time < earliest_time (crossing midnight)
                    if latest_time < earliest_time:
                        latest_time += pd.Timedelta(days=1)

                    # Total worked
                    total_worked = latest_time - earliest_time

                    # Base hours = scheduled hours
                    base_hours = scheduled_end - scheduled_start

                    # Excess hours = total worked - base hours
                    excess_time = max(pd.Timedelta(0), total_worked - base_hours)

                    # ND OT window
                    nd_start = pd.Timedelta(hours=22)
                    nd_end   = pd.Timedelta(hours=6)

                    # Default
                    rd_ot = pd.Timedelta(0)
                    rd_nd_ot = pd.Timedelta(0)
                    rd_nd = pd.Timedelta(0)

                    if excess_time > pd.Timedelta(0):
                        # Split excess_time into OT blocks for validation
                        remaining_excess = excess_time

                        # First hour counts as OT
                        first_hour = min(remaining_excess, pd.Timedelta(hours=1))
                        if latest_time >= nd_start or latest_time < nd_end:
                            rd_nd_ot += first_hour
                        else:
                            rd_ot += first_hour
                        remaining_excess -= first_hour

                        # Remaining excess in ≥30 min chunks
                        if remaining_excess >= pd.Timedelta(minutes=30):
                            full_chunks = remaining_excess // pd.Timedelta(minutes=30)
                            chunk_time = full_chunks * pd.Timedelta(minutes=30)
                            if latest_time >= nd_start or latest_time < nd_end:
                                rd_nd_ot += chunk_time
                            else:
                                rd_ot += chunk_time
                            # leftover <30 min ignored

                    logging.info(f"RD OT DEBUG {schedule} {employee_name} | IN: {in_time} | OUT: {out_time} | RD ND {rd_nd} RD OT {rd_ot} RD ND OT {rd_nd_ot}")

                logging.info(1)
                if not (rd_ot.total_seconds() <= 0 and rd_nd.total_seconds() <= 0 and rd_nd_ot.total_seconds() <= 0):
                    logging.info(22)
                    if row["department"].lower() == "security":
                        # Define time thresholds
                        t_7am = pd.Timedelta(hours=7)
                        t_715am = pd.Timedelta(hours=7, minutes=15)
                        t_7pm = pd.Timedelta(hours=19)
                        t_715pm = pd.Timedelta(hours=19, minutes=15)
                        t_7am_next = pd.Timedelta(hours=31)  # 07:00 next day

                        earliest_time = row["earliest_time"]
                        latest_time = row.get("latest_time", pd.Timedelta("00:00:00"))

                        # Determine which shift is closer to the in time (7 or 19)
                        diff_7am = abs(earliest_time - t_7am)
                        diff_7pm = abs(earliest_time - t_7pm)

                        # Initialize
                        rd_ot_val = 0.0
                        rd_nd_val = 0.0
                        rd_nd_ot_val = 0.0

                        if diff_7am <= diff_7pm:
                            # --- Day shift (7–19) ---
                            if earliest_time <= t_715am and latest_time >= t_7pm:
                                # Within expected range → fixed OT
                                rd_ot_val = 4.0
                                logging.info(f"Security (day shift) fixed OT = {rd_ot_val}")
                            else:
                                # Compute actual worked hours
                                worked_hours = (latest_time - earliest_time).total_seconds() / 3600
                                rd_ot_val = max(0, round(worked_hours - 8, 2))
                                logging.info(f"Security (day shift manual) worked={worked_hours:.2f} hrs, OT={rd_ot_val}")
                        else:
                            # --- Night shift (19–07) ---
                            if latest_time < t_7am:  # wrapped past midnight
                                latest_time += pd.Timedelta(days=1)

                            # define references for 7 PM and 7 AM next day
                                t_7pm = pd.to_timedelta("19:00:00")
                                t_7am_next = pd.to_timedelta("07:00:00") + pd.Timedelta(days=1)

                            if earliest_time <= t_7pm and latest_time >= t_7am_next:
                                    rd_nd_ot_val = 4.0
                                    logging.info(f"Security (night shift) fixed ND OT = {rd_nd_ot_val}")
                            else:
                                worked_hours = (latest_time - earliest_time).total_seconds() / 3600
                                rd_nd_ot_val = max(0, round(worked_hours - 8, 2))
                                logging.info(f"Security (night shift manual) worked={worked_hours:.2f} hrs, ND OT={rd_nd_ot_val}")

                        # --- Log to both DBs ---
                        #log_security_db(conn, row, "OT", rd_ot_val) because only one insert for ot for rd
                        rd_ot_variable = rd_ot_val
                        log_security_db(conn, row, "ND", rd_nd_val + rd_nd_ot_val, biometric_imports_id)
                        

                        log_overtime_to_db(
                            conn,
                            row,
                            ord_ot=0,
                            rd_ot=rd_ot_val,
                            ord_nd=0,
                            ord_nd_ot=0,
                            rd_nd=rd_nd_val,
                            rd_nd_ot=rd_nd_ot_val,
                            rd=0,
                            total_non_working_days_present=0,
                            late=False,
                            late_hours=0,
                            late_minutes=0,
                            out_time_required=out_time_required,
                            type="RD",
                            schedule=schedule,
                            status="Pending",
                            biometric_imports_id=biometric_imports_id,attendance_records_id=row["id"], schedule_shift=schedule_shift,update_target="rd_ot"


                        )

                        # # ✅ Do NOT return any values for security
                        # return

                    else:
                        if rd_ot.total_seconds() != 0 or rd_nd.total_seconds() != 0 or rd_nd_ot.total_seconds() != 0:

                            # Non-security employees
                            rd_ot_val = round(rd_ot.total_seconds() / 3600, 2)
                            rd_nd_val = round(rd_nd.total_seconds() / 3600, 2)
                            rd_nd_ot_val = round(rd_nd_ot.total_seconds() / 3600, 2)
                          
                            log_overtime_to_db(
                                conn,
                                row,
                                ord_ot=0,
                                rd_ot=rd_ot_val,
                                ord_nd=0,
                                ord_nd_ot=0,
                                rd_nd=rd_nd_val,
                                rd_nd_ot=rd_nd_ot_val,
                                rd=0,
                                total_non_working_days_present=0,
                                late=late,
                                late_hours=late_hours,
                                late_minutes=late_minutes,
                                out_time_required=out_time_required,
                                type="RD",
                                schedule=schedule,
                                status="Pending",
                                biometric_imports_id=biometric_imports_id,attendance_records_id=row["id"], schedule_shift=schedule_shift, update_target="rd_ot"
                            )

                    #  Only return values for non-security
                    try:
                        rd_ot_sec = rd_ot_val.total_seconds() if isinstance(rd_ot_val, pd.Timedelta) else 0.0
                        rd_nd_sec = rd_nd_val.total_seconds() if isinstance(rd_nd_val, pd.Timedelta) else 0.0
                        rd_nd_ot_sec = rd_nd_ot_val.total_seconds() if isinstance(rd_nd_ot_val, pd.Timedelta) else 0.0
                        logging.info(44)
                        return [
                            round(rd_ot_sec / 3600, 2),
                            round(rd_nd_sec / 3600, 2),
                            round(rd_nd_ot_sec / 3600, 2),
                        ]
                    except Exception as conv_ex:
                        logging.error(f"Error converting RD OT return values to seconds: {conv_ex}")
                        return [0, 0, 0]
                    return [
                        rd_ot_val,
                        rd_nd_val,
                        rd_nd_ot_val,
                    ]

            except Exception as ex:
                logging.info(f"Error auto‐calculating RD overtime: {ex}")
                return [0, 0, 0]

        

        df[["Ord-OT", "Ord-ND", "Ord-ND-OT"]] = df.apply(autocalculate_ord, axis=1, result_type="expand")
        logging.info("ORD DONE")
        #logging.info("RD OT Flag")
        df[["RD-OT", "RD-ND", "RD-ND-OT"]] = df.apply(autocalculate_rd_overtime, axis=1, result_type="expand")
        logging.info("RD OT DONE")
        #logging.info("D Flag")
        def autocompute_rd(row, data):
            try:
                
               
                # 🔹 Recreate employee match here
                # last_name     = row["last_name"].strip()
                # first_name    = row["first_name"].strip()
                # 1) Pull & clean the record_date
                record_date = str(row["record_date"]).split(" ")[0]
                # --- Skip if marked as leave in attendance_records ---
                if row.get("leaves"):
                    logging.info(f"Leave marked for employee {row.get('employee_management_id')} on {record_date}. Skipping hours calculation.")
                    return 0.0

                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]

                # ✅ Pull temp_sched table directly from PostgreSQL
                #temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments", engine)
                temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)


                #temp_sched_pd["employee_ name"] = temp_sched_pd["last_name"].str.strip() + ", " + temp_sched_pd["first_name"].str.strip()
                #temp_sched_pd["record_date"] = temp_sched_pd["record_date"]  # normalise the column name
                #employee_name = f"{last_name}, {first_name}"
                employee_name = str(row["employee_name"])


               

                match = data[data["employee_name"] == employee_name]
                if match.empty:
                    return 0.0
                #1logging.info(1200)
                schedule = match.iloc[0]["schedule"].strip()
                # First look in temp schedule for that person/date
                temp_match = temp_sched_pd[
                    (temp_sched_pd["employee_name"] == employee_name) &
                    (temp_sched_pd["record_date"] == record_date)
                ]

                if not temp_match.empty:
                    schedule = temp_match.iloc[0]["schedule"]
                    if isinstance(schedule, pd.Series):
                        schedule = schedule.iloc[0]
                else:
                    match = data[data["employee_name"] == employee_name]
                    if match.empty:
                        return 0.0
                    schedule = match.iloc[0]["schedule"]
                    if isinstance(schedule, pd.Series):
                        schedule = schedule.iloc[0]
                earliest_time = row["earliest_time"]  # Timedelta since midnight
                latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
                #logging.info(1300)
                # 4) Determine late‐cutoff (for morning rounding)
                # late_cutoff = pd.to_timedelta("07:15:00") if schedule == "7-16" else pd.to_timedelta("08:15:00")
                if schedule:
                    logging.info(f"schedule: {schedule}")

                    try:
                        # --- Special handling for SECURITY department ---
                        if str(row.get("department", "")).strip().lower() == "security":
                            # Determine which base schedule is closer to the earliest_time
                            seven_am = pd.to_timedelta("07:00:00")
                            seven_pm = pd.to_timedelta("19:00:00")

                            # compute difference in absolute hours
                            diff_to_7 = abs(earliest_time - seven_am)
                            diff_to_19 = abs(earliest_time - seven_pm)

                            # pick whichever is smaller → likely shift start
                            if diff_to_7 <= diff_to_19:
                                schedule = "7-19"
                                logging.info(f"Auto-detected DAY schedule (7-19) for security: {employee_name}")
                            else:
                                schedule = "19-7"
                                logging.info(f"Auto-detected NIGHT schedule (19-7) for security: {employee_name}")
                        # Split schedule like "19-7" → start=19, end=7
                        # Split schedule like "19-7" → start=19, end=7
                        start_str, end_str = schedule.split("-")

                        # Normalize to two digits (e.g., 7 -> 07)
                        start_hour = int(start_str)
                        end_hour = int(end_str)

                        # Format required times as HH:MM:SS
                        start_required = f"{start_hour:02d}:00:00"
                        out_time_required = f"{end_hour:02d}:00:00"

                        # Build late cutoff = start + 15 minutes
                        late_cutoff = pd.to_timedelta(f"{start_hour:02d}:15:00")

                        # Build replacement = start + 1 hour
                        replace_hour = (start_hour + 1) % 24
                        replace_time = pd.to_timedelta(f"{replace_hour:02d}:00:00")

                        

                        # Apply the rule dynamically
                        if earliest_time > late_cutoff:
                            earliest_time = replace_time
                            logging.info(f"Adjusted earliest_time: {earliest_time}")

                    except Exception as e:
                        logging.info(f"Invalid or unrecognized schedule format: {schedule} ({e})")

                #logging.info(1400)
                

                # 2) Only compute on true rest-days
                if record_date not in cleaned_non_working_days:
                    return 0.0
                
                
                if earliest_time == latest_time:
                    return 0.0

                day_shift = schedule in ("7-16", "8-17", "7-19","6-15","9-15","10-18","10-16")
                night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")
                # 3) Parse raw punches into timestamps
                in_td  = pd.to_timedelta(row["earliest_time"], errors="coerce")
                out_td = pd.to_timedelta(row.get("latest_time", "00:00:00"), errors="coerce")
                if pd.isna(in_td) or pd.isna(out_td):
                    return 0.0

                date_base = pd.to_datetime(record_date, format="%Y-%m-%d", errors="coerce")
                in_time   = date_base + earliest_time   # ← use overridden earliest_time
                out_time  = date_base + latest_time     # ← use overridden latest_time
                
                # # 6) Round up all lates
                # late_threshold = date_base + late_cutoff
                # if in_time > late_threshold:
                #     delta = in_time - late_threshold
                #     if delta < pd.Timedelta(hours=1):
                #         in_time = in_time.floor("h") + pd.Timedelta(hours=1)
                # date_base = pd.to_datetime(record_date,errors="coerce")
                # in_time = date_base + earliest_time
                late = False
                late_hours = late_minutes = 0
                morning_limit = date_base + pd.Timedelta("12:00:00")
                
                if date_base <= in_time < morning_limit and earliest_time > late_cutoff:
                    late = True
                    delta = earliest_time - start_required
                    late_hours   = delta.components.hours
                    late_minutes = delta.components.minutes

                     # Only bump if less than 1 hour late
                    if delta < pd.Timedelta(hours=1):
                        in_time = in_time.floor("h") + pd.Timedelta(hours=1)
                        #delta = in_time.time() - start_required  # recompute delta after bump
                        delta = in_time - (date_base + start_required)
                        
                    late = True
                    late_hours   = delta.components.hours
                    late_minutes = delta.components.minutes

                # 4) Handle cross-midnight
                if out_time <= in_time:
                    out_time += pd.Timedelta(days=1)
                if in_time == out_time:
                    return 0.0
               
                # 5) Set up ND window and base-hours limit
                midnight     = date_base + pd.Timedelta(days=1)
                nd_start_td  = pd.Timedelta("22:00:00")
                nd_end_td    = pd.Timedelta("06:00:00")
                base_limit = pd.to_timedelta("09:00:00")
                if schedule in ("15-23", "23-7","9-15"):
                    base_limit = pd.to_timedelta("08:00:00")
                # 6) Walk 1-hour blocks, counting only non-ND in the first 9 h
                worked_base      = pd.Timedelta(0)
                non_nd_base_time = pd.Timedelta(0)
                current = in_time
               
                while current < out_time and worked_base < base_limit:
                    next_hour      = min(current + pd.Timedelta(hours=1), out_time)
                    block          = next_hour - current
                    block_for_base = min(block, base_limit - worked_base)
                    worked_base   += block_for_base

                    # is this block in ND?
                    tod    = current.time()
                    tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                    is_nd  = tod_td >= nd_start_td or tod_td < nd_end_td

                    if not is_nd:
                        non_nd_base_time += block_for_base

                    current = next_hour

                # 7) Subtract 1 h lunch
                # if schedule is 3-23 or 23-7 dont subtract 1 hr
                if schedule.strip() not in ["15-23", "23-7"]:
                    post_lunch = non_nd_base_time - pd.Timedelta(hours=1)
                else:
                    post_lunch = non_nd_base_time

                if post_lunch <= pd.Timedelta(0):
                    hours = 0.0
                else:
                    # 8) Cap at 8 h
                    worked = min(post_lunch, pd.Timedelta("8:00:00"))
                    hours  = round(worked.total_seconds() / 3600, 2)
               
                # logging.info(1900)
                # logging.info(1900)
                if str(schedule).strip() == "15-24":
                    logging.info(f" RD schedule 15-24 ")
                    """
                    This should return 6hrs if earliest >= 15:00 and latest >= 24:00
                    (not late or undertime for RD).
                    """

                    # Calculate total worked time
                    total_worked = latest_time - earliest_time
                    if total_worked < pd.Timedelta(0):
                        total_worked += pd.Timedelta(days=1)

                    # --- Special handling for Rest Day (RD) ---
                    rd_start = pd.to_timedelta("15:00:00")
                    rd_end = pd.to_timedelta("24:00:00")

                    if earliest_time >= rd_start and latest_time >= rd_end:
                        #total_worked = pd.Timedelta(hours=6)  # Fixed 6 hours for RD
                        hours = 6.0

                    logging.info(f"CheckMark sched {schedule} employee {employee_name} ")
                elif str(schedule).strip() == "23-8":
                    logging.info(f" RD schedule 23-8")
                    """
                    This should return 2hrs if earliest >= 23:00 and latest >= 8:00
                    (not late or undertime for RD).
                    """

                    # Calculate total worked time
                    total_worked = latest_time - earliest_time
                    if total_worked < pd.Timedelta(0):
                        total_worked += pd.Timedelta(days=1)

                    # --- Special handling for Rest Day (RD) ---
                    rd_start = pd.to_timedelta("23:00:00")
                    rd_end = pd.to_timedelta("08:00:00")

                    if earliest_time >= rd_start and latest_time >= rd_end:
                        #total_worked = pd.Timedelta(hours=6)  # Fixed 6 hours for RD
                        hours = 2.0

                    logging.info(f"CheckMark sched {schedule} employee {employee_name} ")
                elif str(schedule).strip() == "23-7":
                    logging.info(f" RD schedule 23-7")
                    """
                    This should return 1hrs if earliest >= 15:00 and latest >= 24:00
                    (not late or undertime for RD).
                    """

                    # Calculate total worked time
                    total_worked = latest_time - earliest_time
                    if total_worked < pd.Timedelta(0):
                        total_worked += pd.Timedelta(days=1)

                    # --- Special handling for Rest Day (RD) ---
                    rd_start = pd.to_timedelta("23:00:00")
                    rd_end = pd.to_timedelta("7:00:00")

                    if earliest_time >= rd_start and latest_time >= rd_end:
                        #total_worked = pd.Timedelta(hours=6)  # Fixed 6 hours for RD
                        hours = 1.0

                    logging.info(f"CheckMark sched {schedule} employee {employee_name} ")
                elif day_shift:
                    logging.info(f"Normal schedule {schedule} employee {employee_name} following RD logic")

                    # Total worked time, adjust if crossed midnight
                    total_worked = latest_time - earliest_time
                    if total_worked < pd.Timedelta(0):
                        total_worked += pd.Timedelta(days=1)

                    # RD-like window based on schedule
                    start_hour, end_hour = map(int, schedule.split("-"))
                    rd_start = pd.to_timedelta(f"{start_hour}:00:00")
                    rd_end = pd.to_timedelta(f"{end_hour}:00:00")

                    # Handle overnight schedule
                    if rd_end <= rd_start:
                        rd_end += pd.Timedelta(days=1)

                    # If employee punches cover the schedule window (earlier in, later out)
                    if earliest_time <= rd_start and latest_time >= rd_end:
                        hours = (rd_end - rd_start).total_seconds() / 3600  # Full schedule hours
                        logging.info(f"Employee {employee_name} worked full schedule {schedule}, hours set to {hours}")
                        hours = 8.0

                
                if hours > 0:
                    if row["department"].lower() == "security":
                        # --- Security: RD logging with computation like ORD ---
                        t_7am = pd.Timedelta(hours=7)
                        t_715am = pd.Timedelta(hours=7, minutes=15)
                        t_7pm = pd.Timedelta(hours=19)
                        t_715pm = pd.Timedelta(hours=19, minutes=15)
                        t_7am_next = pd.Timedelta(hours=31)  # 07:00 next day

                        # earliest_time = row["earliest_time"]
                        # latest_time = row.get("latest_time", pd.Timedelta("00:00:00"))

                        # Determine which shift is closer to the in time (7 or 19)
                        diff_7am = abs(earliest_time - t_7am)
                        diff_7pm = abs(earliest_time - t_7pm)

                        # Initialize RD values
                        rd_ot_val = 0.0
                        rd_nd_val = 0.0
                        rd_nd_ot_val = 0.0

                        if diff_7am <= diff_7pm:
                            # --- Day shift (7–19) ---
                            if earliest_time <= t_715am and latest_time >= t_7pm:
                                # Within expected range → fixed RD OT
                                rd_ot_val = 4.0
                                logging.info(f"Security (day shift) fixed RD = {rd_ot_val}")
                            else:
                                # Compute actual worked hours
                                worked_hours = (latest_time - earliest_time).total_seconds() / 3600
                                rd_ot_val = max(0, round(worked_hours - 8, 2))
                                logging.info(f"Security (day shift manual) worked={worked_hours:.2f} hrs, RD={rd_ot_val}")
                        else:
                            # --- Night shift (19–07) ---
                            if latest_time < t_7am:  # wrapped past midnight
                                latest_time += pd.Timedelta(days=1)

                            # define references for 7 PM and 7 AM next day
                            t_7pm = pd.to_timedelta("19:00:00")
                            t_7am_next = pd.to_timedelta("07:00:00") + pd.Timedelta(days=1)

                            if earliest_time <= t_7pm and latest_time >= t_7am_next:
                                    rd_nd_ot_val = 4.0
                                    logging.info(f"Security (night shift) fixed RD ND OT = {rd_nd_ot_val}")
                            else:
                                worked_hours = (latest_time - earliest_time).total_seconds() / 3600
                                rd_nd_ot_val = max(0, round(worked_hours - 8, 2))
                                logging.info(f"Security (night shift manual) worked={worked_hours:.2f} hrs, RD ND OT={rd_nd_ot_val}")

                        

                        # --- Log to both DBs ---
                        #all_rd = rd_ot_variable + rd_val
                        
                        # log_security_db(conn, row, "OT", all_rd, biometric_imports_id)

                       

                        log_overtime_to_db(
                            conn,
                            row,
                            ord_ot=0,
                            rd_ot=rd_ot_val,
                            ord_nd=0,
                            ord_nd_ot=0,
                            rd_nd=rd_nd_val,
                            rd_nd_ot=rd_nd_ot_val,
                            rd=0,
                            total_non_working_days_present=0,
                            late=late,
                            late_hours=late_hours,
                            late_minutes=late_minutes,
                            out_time_required=out_time_required,
                            type="RD",
                            schedule=schedule,
                            status="Pending",
                            biometric_imports_id=biometric_imports_id,attendance_records_id=row["id"], schedule_shift="day shift", update_target="rd"
                        )

                        # # ✅ Do NOT return any values for security
                        # return
                        return 0.0

                    else:
                        # Non-security employees
                       
                       
                        log_overtime_to_db(
                            conn,
                            row,
                            ord_ot=0,
                            rd_ot=0,
                            ord_nd=0,
                            ord_nd_ot=0,
                            rd_nd=0,
                            rd_nd_ot=0,
                            rd=hours,
                            total_non_working_days_present=0,
                            late=late,
                            late_hours=late_hours,
                            late_minutes=late_minutes,
                            out_time_required=out_time_required,
                            type="RD",
                            schedule=schedule,
                            status="Pending",
                            biometric_imports_id=biometric_imports_id,attendance_records_id=row["id"], schedule_shift="day shift",update_target="rd"
                        )
                       
                        logging.info(f"rd employee_name {employee_name} record date{record_date} hours{hours} earliest {earliest_time} latest {latest_time} ")

                    # ✅ Only return hours for non-security
                    return hours

            except Exception as e:
                logging.info(f"Error auto-computing RD hours: {e}")
                return 0.0


        df["RD"] = df.apply(autocompute_rd, axis=1, args=(data,))
        logging.info("RD DONE")

      
        

               
        
        return df

    except Exception as ex:
        logging.info(f"Error calculating hours worked: {ex}")




def main(
    input_csv_file,
    output_directory,
    image_pathway,
    biometric_imports_id,

):
    
    """Main function to orchestrate the employee data processing."""
    try:    
        

        # convert File to CSV and Format before 
        input_csv_file = convert_file(input_csv_file,output_directory, biometric_imports_id)

        df, data = load_data_from_db(biometric_imports_id=biometric_imports_id)

        if df is None or data is None:
            # logging.info("ailed to read CSV files.")
            return

        # # Preprocessing names, merging data, calculating hours, etc.
        df = calculate_hours_worked(df,data, biometric_imports_id)
        merge_all_rd_entries(conn=conn)
        print("Successful")
        

    except Exception as ex:
        logging.info(f"Error in main: {ex}")


if __name__ == "__main__":

    # Argument parser setups
    parser = argparse.ArgumentParser(description="Process employee attendance data.")
    parser.add_argument(
        "input_csv_file", type=str, help="The path to the main employee input CSV file"
    )
    parser.add_argument(
        "output_directory", type=str, help="The directory where output files will be saved"
    )
    parser.add_argument(
        "image_pathway", type=str, help="The directory where is the image"
    )
    parser.add_argument(
        "biometric_imports_id", type=str, help="The number of biometric_id"
    )


    args = parser.parse_args()

    # Call the main function with the provided arguments
    main(
        args.input_csv_file,
        args.output_directory,
        args.image_pathway,
        args.biometric_imports_id,
    )



