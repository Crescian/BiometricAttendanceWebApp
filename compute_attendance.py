import os
import re
import json
import math
import csv
import threading
import tempfile
import logging
import warnings
import datetime
from datetime import timedelta
import pandas as pd
import numpy as np
import holidays
import argparse
import psycopg2
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from urllib.parse import quote_plus
import openpyxl
from openpyxl import load_workbook
from openpyxl.drawing.image import Image
from openpyxl.styles import Alignment, Font, Border, Side, PatternFill
from openpyxl.utils import get_column_letter, column_index_from_string
from openpyxl.comments import Comment
from autocompute_attendance import log_security_db, conn, engine
warnings.filterwarnings("ignore", message="pandas only supports SQLAlchemy")
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)
# Configure logging
logging.basicConfig(
    filename='app.log',       # Log file name
    filemode='w',             # 'a' to append, 'w' to overwrite
    format='%(asctime)s - %(levelname)s - %(message)s',  # Log format
    level=logging.DEBUG        # Minimum level of messages to log
)

rd_ot_variable = 0


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




def update_leaves_attendance_record(biometric_imports_id):
    try:
        """
        Sync leaves field in attendance_records with the leaves table.
        For all attendance_records where a matching leaves row exists
        (same employee_management_id, record_date, biometric_imports_id),
        set attendance_records.leaves = TRUE if it's currently FALSE or NULL.
        """
        with engine.begin() as connection:  # auto-commit/rollback
            logging.info(f"Checking and updating attendance_records for biometric_imports_id={biometric_imports_id}")

            update_sql = text("""
                UPDATE attendance_records
                SET leaves = TRUE
                WHERE (leaves IS NULL OR leaves = FALSE)
                  AND biometric_imports_id = :biometric_imports_id
                  AND EXISTS (
                      SELECT 1
                      FROM leaves
                      WHERE leaves.employee_management_id = attendance_records.employee_management_id
                        AND leaves.record_date = attendance_records.record_date
                        AND leaves.biometric_imports_id = :biometric_imports_id
                  );
            """)

            result = connection.execute(update_sql, {"biometric_imports_id": biometric_imports_id})
            rows_updated = result.rowcount or 0

            logging.info(f"{rows_updated} attendance record(s) updated to leaves = TRUE.")
            return rows_updated

    except Exception as e:
        logging.exception(f"Error Update Leaves: {e}")
        return None




def log_dtr_db(conn, row, insert_type, hours, biometric_imports_id, custom_dates_df):
    try:
        """
        this are the fields of dtr_report employee_management_id, type, record_date, biometrics_import_id
        if type is hours_worked then just insert it to dtr_report
        if type is rd, ot, rd_ot then checked into the custom dates table if it is holiday by using record_date of row

        """
        row_types = [
            "Hours Worked","OT (Ordinary day)","SUNDAY Reg 8 hrs","SPECIAL HOL. Reg 8 hrs",
            "SPECIAL HOL. + SUNDAY Reg 8 hrs","LEG. HOLIDAY Reg 8 hrs","LEG. HOLIDAY + SUNDAY Reg 8 hrs",
            "LEG. HOLIDAY + LEG. HOLIDAY Reg 8 hrs","LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY Reg 8 hrs",
            "ND Reg 8 hrs","SUNDAY ND Reg 8 hrs","SPECIAL HOL. ND Reg 8 hrs",
            "SPECIAL HOL. + SUNDAY ND Reg 8 hrs","LEG. HOLIDAY ND Reg 8 hrs","LEG. HOLIDAY + SUNDAY ND Reg 8 hrs",
            "LEG. HOLIDAY + LEG. HOLIDAY ND Reg 8 hrs","LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY ND Reg 8 hrs",
            "EX SUNDAY OT","EX SPECIAL HOL. OT","EX SPECIAL HOL. + SUNDAY OT","EX LEG. HOLIDAY OT",
            "EX. LEG HOLIDAY + SUNDAY OT","EX. LEG. HOLIDAY + LEG. HOLIDAY OT",
            "EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY OT","EX. NDOT","EX. SUNDAY NDOT",
            "EX. SPECIAL HOL. NDOT","EX. SPECIAL HOL. + SUNDAY NDOT","EX. LEG. HOLIDAY NDOT",
            "EX. LEG. HOLIDAY + SUNDAY NDOT","EX. LEG. HOLIDAY + LEG. HOLIDAY NDOT",
            "EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY NDOT", " "
        ]
        
        """
        if insert_type is hours_worked okay insert is Hours Worked
        if insert_type is ord ot the type to insert is OT (Ordinary day)
        if insert type is ord_nd : ND Reg 8 hrs
        if insert type is ord_nd_ot: EX. NDOT
        if insert type is rd  check if record date is in custom date table if not it is Sunday Reg 8hrs
        if insert type is rd if record date is in cutstom date table if value in custom date table is regular holiday the then it is LEG. Holiday Reg 8hrs
        if insert type is rd if record date is in cutstom date table if value in custom date table is special non-working holiday the then it is SPECIAL HOL. Reg 8hrs
        if insert type is rd if record date is in cutstom date table if value in custom date table is special non-working holiday then is both a regular rest day the then it is SPECIAL HOL. + SUNDAY Reg 8 hrs
        if insert type is rd if record date is in cutstom date table if value in custom date table is regular holiday the then it is LEG. Holiday Reg 8hrs
        if insert type is rd f record date is in cutstom date table if value in custom date table is both regular holiday then is a regular rest day this when you query and in the database there is two then it is LEG. HOLIDAY + SUNDAY Reg 8 hrs
        if insert type is rd f record date is in cutstom date table if value in custom date table is both regular holiday then is a another regulary holiday this when you query and in the database there is two then it is LEG. HOLIDAY + LEG. HOLIDAY Reg 8 hrs
        if insert type is rd f record date is in cutstom date table if value in custom date table is both regular holiday then is a another regulary holiday and a regular rest day this when you query and in the database there is three then it is LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY Reg 8 hrs

        if insert type is rd_nd  check if record date is in custom date table if not it is Sunday ND Reg 8hrs
        if insert type is rd_nd if record date is in cutstom date table if value in custom date table is regular holiday the then it is LEG. Holiday ND Reg 8hrs
        if insert type is rd_nd if record date is in cutstom date table if value in custom date table is special non-working holiday the then it is SPECIAL HOL. ND + SUNDAY ND Reg 8 hrs
        if insert type is rd_nd if record date is in cutstom date table if value in custom date table is regular holiday the then it is LEG. Holiday ND Reg 8hrs
        if insert type is rd_nd f record date is in cutstom date table if value in custom date table is both regular holiday then is a regular rest day this when you query and in the database there is two then it is LEG. HOLIDAY + SUNDAY  ND Reg 8 hrs
        if insert type is rd_nd f record date is in cutstom date table if value in custom date table is both regular holiday then is a another regulary holiday this when you query and in the database there is two then it is LEG. HOLIDAY + LEG. HOLIDAY ND Reg 8 hrs
        if insert type is rd_nd f record date is in cutstom date table if value in custom date table is both regular holiday then is a another regulary holiday and a regular rest day this when you query and in the database there is three then it is LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY ND Reg 8 hrs

        if insert type is rd_nd_ot  check if record date is in custom date table if not it is EX SUNDAY OT
        if insert type is rd_nd_ot if record date is in cutstom date table if value in custom date table is regular holiday the then it is EX. LEG. Holiday OT
        if insert type is rd_nd_ot if record date is in cutstom date table if value in custom date table is special non-working holiday the then it is EX. SPECIAL HOL. ND + SUNDAY OT
        if insert type is rd_nd_ot if record date is in cutstom date table if value in custom date table is regular holiday the then it is EX. LEG. Holiday OT
        if insert type is rd_nd_ot f record date is in cutstom date table if value in custom date table is both regular holiday then is a regular rest day this when you query and in the database there is two then it is EX LEG. HOLIDAY + SUNDAY OT
        if insert type is rd_nd_ot f record date is in cutstom date table if value in custom date table is both regular holiday then is a another regulary holiday this when you query and in the database there is two then it is EX. LEG. HOLIDAY + LEG. HOLIDAY OT
        if insert type is rd_nd_ot f record date is in cutstom date table if value in custom date table is both regular holiday then is a another regulary holiday and a regular rest day this when you query and in the database there is three then it is EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY OT
        """
        employee_name = str(row["employee_name"])
        record_date = str(row["record_date"]).split(" ")[0]
        earliest_time = str(row["earliest_time"])
        latest_time = str(row["latest_time"])

       
        
        # --- Step 1: Determine type to insert based on insert_type and custom_dates_df ---
        # Filter all holidays for the record date
        holidays_for_date = custom_dates_df[custom_dates_df['record_date'] == record_date]['holiday_type'].tolist()
        rest_day_count = holidays_for_date.count("Rest Day")
        regular_holiday_count = holidays_for_date.count("Regular Holiday")
        special_holiday_count = holidays_for_date.count("Special Non-Working Holiday")
        total_holiday_count = len(holidays_for_date)

        # Determine type_to_insert following your comment logic
        type_to_insert = None

        if insert_type == "hours_worked":
            type_to_insert = "Hours Worked"
        elif insert_type == "adjustment":
            type_to_insert = "Adjustment"
        elif insert_type == "ord_ot":
            type_to_insert = "OT (Ordinary day)"
        elif insert_type == "ord_nd":
            type_to_insert = "ND Reg 8 hrs"
        elif insert_type == "ord_nd_ot":
            type_to_insert = "EX. NDOT"
        elif insert_type == "rd":
            if total_holiday_count == 0:
                type_to_insert = "SUNDAY Reg 8 hrs"
            elif rest_day_count == 1 and regular_holiday_count == 0 and special_holiday_count == 0:
                type_to_insert = "SUNDAY Reg 8 hrs"
            elif regular_holiday_count == 1 and rest_day_count == 0:
                type_to_insert = "LEG. HOLIDAY Reg 8 hrs"
            elif special_holiday_count == 1 and rest_day_count == 0:
                type_to_insert = "SPECIAL HOL. Reg 8 hrs"
            elif special_holiday_count == 1 and rest_day_count == 1:
                type_to_insert = "SPECIAL HOL. + SUNDAY Reg 8 hrs"
            elif regular_holiday_count == 1 and rest_day_count == 1:
                type_to_insert = "LEG. HOLIDAY + SUNDAY Reg 8 hrs"
            elif regular_holiday_count == 2 and rest_day_count == 0:
                type_to_insert = "LEG. HOLIDAY + LEG. HOLIDAY Reg 8 hrs"
            elif regular_holiday_count == 2 and rest_day_count == 1:
                type_to_insert = "LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY Reg 8 hrs"
        elif insert_type == "rd_nd":
            if total_holiday_count == 0:
                type_to_insert = "SUNDAY ND Reg 8 hrs"
            elif regular_holiday_count == 1 and rest_day_count == 0:
                type_to_insert = "LEG. HOLIDAY ND Reg 8 hrs"
            elif special_holiday_count == 1 and rest_day_count == 0:
                type_to_insert = "SPECIAL HOL. ND Reg 8 hrs"
            elif rest_day_count == 1 and special_holiday_count == 1:
                type_to_insert = "SPECIAL HOL. + SUNDAY ND Reg 8 hrs"
            elif rest_day_count == 1 and regular_holiday_count == 1:
                type_to_insert = "LEG. HOLIDAY + SUNDAY ND Reg 8 hrs"
            elif regular_holiday_count == 2 and rest_day_count == 0:
                type_to_insert = "LEG. HOLIDAY + LEG. HOLIDAY ND Reg 8 hrs"
            elif regular_holiday_count == 2 and rest_day_count == 1:
                type_to_insert = "LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY ND Reg 8 hrs"
        elif insert_type == "rd_nd_ot":
            if total_holiday_count == 0:
                type_to_insert = "EX SUNDAY OT"
            elif regular_holiday_count == 1 and rest_day_count == 0:
                type_to_insert = "EX. LEG. HOLIDAY OT"
            elif special_holiday_count == 1 and rest_day_count == 1:
                type_to_insert = "EX. SPECIAL HOL. + SUNDAY OT"
            elif regular_holiday_count == 1 and rest_day_count == 1:
                type_to_insert = "EX. LEG HOLIDAY + SUNDAY OT"
            elif regular_holiday_count == 2 and rest_day_count == 0:
                type_to_insert = "EX. LEG. HOLIDAY + LEG. HOLIDAY OT"
            elif regular_holiday_count == 2 and rest_day_count == 1:
                type_to_insert = "EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY OT"

        # --- Step 2: Get employee_management_id ---
        with conn.cursor() as cur:
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
            if isinstance(hours, (pd.Timedelta, datetime.timedelta)):
                hours = hours.total_seconds() / 3600
            elif isinstance(hours, str) and "day" in hours:
                try:
                    hours = pd.to_timedelta(hours).total_seconds() / 3600
                except Exception:
                    pass

            # --- Step 3: Insert into dtr_report if not exists ---
            cur.execute("""
                SELECT 1 FROM dtr_report
                WHERE employee_management_id = %s
                AND type = %s
                AND record_date = %s
                AND biometric_imports_id = %s
                LIMIT 1;
            """, (employee_id, type_to_insert, record_date, biometric_imports_id))
            existing = cur.fetchone()

            if existing:
                logging.info(f"Skipped {type_to_insert} for {employee_name} ({record_date}) — already exists.")
            else:
                cur.execute("""
                    INSERT INTO dtr_report
                    (employee_management_id, type, record_date, biometric_imports_id, hours)
                    VALUES (%s, %s, %s, %s, %s);
                """, (employee_id, type_to_insert, record_date, biometric_imports_id, hours))
                conn.commit()
                logging.info(f"Inserted {type_to_insert} for {employee_name} ({record_date}).")

     

    except Exception as ex:
        logging.info(f"Error report manual: {ex}")
        


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
            pass
            #calculate_total_non_workingdays(current_year, engine)

        # Get all non-working days from custom_dates table
        custom_dates_df = pd.read_sql("SELECT record_date,holiday_type FROM custom_dates", engine)
        non_working_days = custom_dates_df['record_date'].astype(str).tolist()
        overtimes = pd.read_sql("SELECT type, last_name, first_name, record_date FROM overtimes", engine)
        
        def calculate_row_hours(row):
            try:
                # last_name = str(row.get("last_name") or row.get("Last Name") or "").strip()
                # first_name = str(row.get("first_name") or row.get("First Name") or "").strip()
                employee_name = str(row.get("employee_name")).strip()
                logging.info(f"employee name {employee_name} row hours")
                # record_date = str(row.get("record_date") or "").replace("'", "").strip()
                record_date = str(row["record_date"]).split(" ")[0]
                logging.info(f"record_date value: {record_date} (type: {type(record_date)})")
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        SELECT id, employee_name, record_date, earliest_time, latest_time
                        FROM overtimes
                        WHERE employee_name = %s
                        AND record_date = %s
                        AND status = 'Approved'
                        LIMIT 1;
                        """,
                        (employee_name, record_date))
                    employee_record = cur.fetchone()

                    cur.execute(
                        """
                        SELECT EXISTS(
                            SELECT 1
                            FROM certificate_attendance AS ca
                            INNER JOIN attendance_records AS ar
                                ON ca.attendance_records_id = ar.id
                            WHERE ar.record_date = %s
                            AND ca.is_cutoff = false
                        );
                        """,
                        (record_date,)
                    )
                    is_cutoff_false = bool(cur.fetchone()[0])

                   

               


                for non_working_day in non_working_days:
                    non_working_day = non_working_day.replace("'", "").strip()
                    # if record_date == non_working_day and not employee_record:
                    #     return 0
                    if record_date == non_working_day:
                        return 0
                #print(non_working_days)
                if row.get("leaves"):
                    logging.info(f"Leave marked for employee {row.get('employee_management_id')} on {record_date}. Skipping hours calculation.")
                    return 0
                
                # Validate earliest and latest times
                if pd.isna(row["earliest_time"]) or pd.isna(row["latest_time"]):
                    # print("Invalid Earliest Time or Latest Time. Hours calculated: 0")
                    return 0

                # Handle case where Earliest Time and Latest Time are the same
                if row["earliest_time"] == row["latest_time"]:
                    # print("Earliest Time and Latest Time are the same. Hours calculated: 0")
                    return 0
                earliest_time = pd.to_timedelta(row["earliest_time"])
                latest_time = pd.to_timedelta(row["latest_time"])
               
                
                temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)


              
                
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
                    logging.info(f"temp schedule override found: {schedule}")
                else:
                    match = data[data["employee_name"] == employee_name]
                    if match.empty:
                        #return [0, 0, 0]
                        return 0
                    schedule = match.iloc[0]["schedule"]
                    if isinstance(schedule, pd.Series):
                        schedule = schedule.iloc[0]
                    #logging.info(f"using employee_management schedule: {schedule}")

                if schedule:
                    logging.info(f"Employee {employee_name} schedule: {schedule}")

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


                
                if employee_record:
                    # Override times if employee record exists
                    earliest_time = pd.to_timedelta(employee_record[3])
                    latest_time = pd.to_timedelta(employee_record[4])
                    logging.info(f"in and out override by Employee {employee_name}")
    

                # Calculate hours worked
                if pd.notna(earliest_time) and pd.notna(latest_time):
                    if earliest_time <= latest_time:
                        # Times are on the same day
                        hours = (latest_time - earliest_time).total_seconds() / 3600.0
                        # print(f"imes are on the same day. Hours calculated: {hours}")
                    else:
                        # Times cross midnight
                        hours = (
                            (latest_time + pd.Timedelta(hours=24)) - earliest_time
                        ).total_seconds() / 3600.0
                        # print(f"imes cross midnight. Hours calculated: {hours}")

                    # Subtract 1 hour for breaks (if applicable) and ensure non-negative hours    
                    adjusted_hours = max(hours - 1, 0)
                    if (schedule.strip() == "15-23" or schedule.strip() == "23-7" or schedule == "7-19" or schedule == "19-7" or schedule == "9-15"):
                        adjusted_hours = hours
                    # logging.info(f"Adjusted hours: {adjusted_hours}")
                    

                    
                    # Cap hours to 8 if no employee record is found — except for security department
                    if (not employee_record and adjusted_hours > 8 and str(row.get("department", "")).strip().lower() != "security"):
                        adjusted_hours = 8

                    # If less than 8, return the rounded value using round()
                    if adjusted_hours < 8:
                        rounded_hours = round(adjusted_hours)
                        logging.info(f"Less than 8 hours: {rounded_hours}")
                        if row["department"].lower() != "security":
                            if is_cutoff_false:
                                log_dtr_db(conn, row, "adjustment",adjusted_hours, biometric_imports_id, custom_dates_df)
                            else:
                                log_dtr_db(conn, row, "hours_worked",adjusted_hours, biometric_imports_id, custom_dates_df)
                                logging.info(f"HOURS WORKED CHECKED {employee_name} hours worked{rounded_hours} record_date{record_date}")
                        elif row["department"].lower() == "security":
                            #log_security_db(conn, row, "hours_worked", 12)
                            log_security_db(conn, row, "hours_worked", adjusted_hours, biometric_imports_id=biometric_imports_id,attendance_records_id=row["id"] ) 
                            return rounded_hours

                    # Otherwise, round and return using round()
                    rounded_hours = min(adjusted_hours, 8)
                    logging.info(rounded_hours)
                    # insert it to log security db if department is equal to security
                    if row["department"].lower() != "security":
                        if is_cutoff_false:
                            log_dtr_db(conn, row, "adjustment",rounded_hours, biometric_imports_id, custom_dates_df)
                        else:
                            log_dtr_db(conn, row, "hours_worked",rounded_hours, biometric_imports_id, custom_dates_df)
                            logging.info(f"HOURS WORKED CHECKED {employee_name} hours worked{rounded_hours} record_date{record_date}")
                    elif row["department"].lower() == "security":
                        #log_security_db(conn, row, "hours_worked", 12)
                        log_security_db(conn, row, "hours_worked", rounded_hours, biometric_imports_id=biometric_imports_id,attendance_records_id=row["id"] ) 
                       
                    return rounded_hours

                return 0
            except Exception as ex:
                logging.info(f"Error calculating row hours: {ex}")
                return 0

        # Apply the helper function to the DataFrame
        df["Hours Worked"] = df.apply(calculate_row_hours, axis=1)

        # Replace NaN or infinite values with 0
        df["Hours Worked"] = (
            df["Hours Worked"].replace([np.inf, -np.inf], np.nan).fillna(0)
        )
       
        
        def calculate_ord(row):
            try:
                
                # 1) Identify date & skip non‐working days
            
                # last_name = str(row.get("last_name") or row.get("Last Name") or "").strip()
                # first_name = str(row.get("first_name") or row.get("First Name") or "").strip()
                logging.info("Info1")
                employee_name = str(row.get("employee_name")).strip()
                record_date = str(row["record_date"]).split(" ")[0]
                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]

                if record_date in cleaned_non_working_days:
                    # logging.info(f"DEBUG Skip record date: {record_date}")
                    return [0, 0, 0]

                earliest_time = row["earliest_time"]  # Timedelta since midnight
                latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
                # logging.info(f"DEBUG Earliest: {earliest_time}  Latest: {latest_time}")

                if earliest_time == latest_time:
                    logging.info("DEBUG ORD Same earliest == latest -> skip")
                    return [0, 0, 0]

                # 2a) Override with overtime_approve table if available
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        SELECT type, employee_name, record_date, earliest_time, latest_time
                        FROM overtimes
                        WHERE type = %s
                        AND employee_name = %s
                        AND TO_CHAR(record_date, 'YYYY-MM-DD') = %s
                        AND status = 'Approved'
                        LIMIT 1;
                        """,
                        (
                            "ORD",
                            employee_name,
                            record_date,
                        ),
                    )
                    employee_record = cur.fetchone()

                if employee_record:
                    # Replace earliest/latest with record values
                    earliest_time = pd.to_timedelta(employee_record[3])
                    latest_time = pd.to_timedelta(employee_record[4])
                    logging.info(f"DEBUG OVERTIME OVERRIDE -> Earliest: {earliest_time}  Latest: {latest_time}")
                # else:
                #     logging.info("DEBUG No overtime override")

                # 2) Lookup schedule & determine late cutoff + required out time
               
                
                temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)

                # Build the combined name
                # employee_name = f"{last_name}, {first_name}"
                logging.info(f"ord {employee_name}")
                # First look in temp schedule for that person/date
                temp_match = temp_sched_pd[
                    (temp_sched_pd["employee_name"] == employee_name) &
                    (temp_sched_pd["record_date"] == record_date)
                ]
                logging.info("Info2")
                # if not temp_match.empty:
                #     # use temp schedule
                #     #schedule = temp_match.iloc[0]["schedule"]
                #     schedule_val = temp_match.iloc[0]["schedule"]
                #     if isinstance(schedule_val, pd.Series):
                #         schedule_val = schedule_val.item()  # get scalar
                #     schedule = str(schedule_val).strip()
                #     logging.info(f"DEBUG using temp schedule {schedule} for {employee_name} on {record_date}")
                # else:
                #     # fall back to the normal schedule table
                #     match = data[data["employee_name"] == employee_name]
                #     if match.empty:
                #         logging.info(f"DEBUG no schedule found in data for {employee_name} -> return 0.0")
                #         return [0,0,0]
                #     # schedule = match.iloc[0]["schedule"].strip()
                #     schedule_val = match.iloc[0]["schedule"]
                #     if isinstance(schedule_val, pd.Series):
                #         schedule_val = schedule_val.item()
                #     schedule = str(schedule_val).strip()
                #     logging.info(f"DEBUG using default schedule {schedule} for {employee_name}")
                if not temp_match.empty:
                    # temp_match is filtered DataFrame
                    schedule = str(temp_match["schedule"].values[0]).strip()
                    logging.info(f"DEBUG using temp schedule {schedule} for {employee_name} on {record_date}")
                else:
                    match = data[data["employee_name"] == employee_name]
                    if match.empty:
                        logging.info(f"DEBUG no schedule found in data for {employee_name} -> return 0.0")
                        return [0, 0, 0]
                    schedule = str(match["schedule"].values[0]).strip()
                    logging.info(f"DEBUG using default schedule {schedule} for {employee_name}")

                night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")
                logging.info(f"DEBUG night_shift={night_shift} schedule={schedule}")

                if not employee_record and not night_shift:
                    logging.info(f"DEBUG not employee_record and not night_shift -> skip {employee_name} {record_date}")
                    return [0, 0, 0]
                
                logging.info("Info3")

                # schedule to requirements
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
                
                logging.info("Info4")
                # 3) Detect late (but only if punch is before noon)
                date_base = pd.to_datetime(record_date,errors="coerce")
                in_time       = date_base + earliest_time

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
                        delta = in_time - (date_base + start_required)

                    late = True
                    late_hours   = delta.components.hours
                    late_minutes = delta.components.minutes

                # 4) Compute out_time and fix overnight
                out_time = date_base + latest_time
                logging.info(f"DEBUG in_time (before adjust): {in_time}  out_time (before adjust): {out_time}")
                if out_time <= in_time:
                    out_time += pd.Timedelta(days=1)
                    logging.info(f"DEBUG out_time adjusted to next day: {out_time}")
                if in_time == out_time:
                    logging.info("DEBUG in_time == out_time -> skip")
                    return [0, 0, 0]

                # Determine flags
                day_shift = schedule in ("7-16", "8-17", "7-19","6-15","9-15","10-18","10-16")
                night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")

                ord_nd    = pd.Timedelta(0)
                ord_ot    = pd.Timedelta(0)
                ord_nd_ot = pd.Timedelta(0)
                worked    = pd.Timedelta(0)

                nd_start   = pd.to_timedelta("22:00:00")
                nd_end     = pd.to_timedelta("06:00:00")
                base_hours = pd.to_timedelta("09:00:00")
                if schedule in ("15-23","23-7"):
                    base_hours = pd.to_timedelta("08:00:00")

                ot_blocks = []  # list of (duration, is_nd)

                # logging.info(f"DEBUG starting loop: in_time={in_time}, out_time={out_time}, schedule={schedule}, base_hours={base_hours}")

                current = in_time
                while current < out_time:
                    next_hour = min(current + pd.Timedelta(hours=1), out_time)
                    block     = next_hour - current

                    # determine if this block is ND
                    tod    = current.time()
                    tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                    is_nd  = (tod_td >= nd_start) or (tod_td < nd_end)

                    # logging.info(f"DEBUG loop block: current={current}, next_hour={next_hour}, block={block}, tod_td={tod_td}, is_nd={is_nd}, worked_so_far={worked}")

                    if day_shift:
                        # day shift: normal rule (need to reach base hours first)
                        if worked < base_hours:
                            if is_nd:
                                # ND during base hours for day shift goes directly to ND-OT
                                ot_blocks.append((block, True))
                                # logging.info(f"DEBUG day_shift: ND during base -> OT_block added: {block}")
                            else:
                                worked += block
                                # logging.info(f"DEBUG day_shift: non-ND base increment -> worked now {worked}")
                        else:
                            ot_blocks.append((block, is_nd))
                            # logging.info(f"DEBUG day_shift: OT_block added: {block}, is_nd={is_nd}")

                    elif night_shift:
                        # For no employee record, we still process all blocks but adjust ND calculation
                        if worked < base_hours:
                            remaining_base = base_hours - worked

                            # calculate actual ND portion inside this block
                            nd_block = pd.Timedelta(0)

                            # shift boundaries
                            shift_start = current
                            shift_end = current + block

                            # ND window boundaries: 22:00–06:00 (spans midnight)
                            tod = current.time()
                            tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                            nd_start_td = pd.to_timedelta("22:00:00")
                            nd_end_td = pd.to_timedelta("06:00:00")
                            is_nd_local = (tod_td >= nd_start_td) or (tod_td < nd_end_td)

                            # If no employee record, only count ND from schedule start time
                            if not employee_record:
                                schedule_start_hour = schedule.split("-")[0]
                                schedule_start_td = pd.to_timedelta(f"{schedule_start_hour}:00:00")
                                if schedule_start_hour in ["18", "19", "20", "21", "22", "23"]:
                                    if tod_td >= schedule_start_td or tod_td < pd.to_timedelta("06:00:00"):
                                        pass
                                    else:
                                        is_nd_local = False
                                else:
                                    is_nd_local = is_nd_local and (tod_td >= schedule_start_td)

                            # If this block is ND, the entire block is ND
                            if is_nd_local:
                                nd_block = block
                            else:
                                nd_block = pd.Timedelta(0)

                            logging.info(f"DEBUG night_shift block: is_nd_local={is_nd_local}, nd_block={nd_block}, remaining_base={remaining_base}")

                            # cap ND to remaining base
                            nd_block = min(nd_block, remaining_base)
                            worked_block = min(block, remaining_base)
                            worked += worked_block

                            ord_nd += nd_block
                            non_nd_base = worked_block - nd_block
                            if non_nd_base > pd.Timedelta(0):
                                pass

                            # remainder becomes OT
                            second_part = block - worked_block
                            if second_part > pd.Timedelta(0):
                                if employee_record:
                                    ot_blocks.append((second_part, is_nd_local))
                                    # logging.info(f"DEBUG night_shift: OT_block added (second_part): {second_part}, is_nd={is_nd_local}")
                                else:
                                    logging.info("DEBUG night_shift: skipping OT_block because no employee_record")
                        else:
                            if employee_record:
                                ot_blocks.append((block, is_nd))
                                logging.info(f"DEBUG night_shift: OT_block added (worked >= base): {block}, is_nd={is_nd}")
                            else:
                                logging.info("DEBUG night_shift: skipping OT (worked >= base but no employee_record)")

                    current = next_hour

                    # --- OT Handling ---
                    ot_total = sum((b for b, _ in ot_blocks), pd.Timedelta(0))

                    if ot_total >= pd.Timedelta(hours=1):
                        remaining_first_hour = pd.Timedelta(hours=1)

                        for block, is_nd in ot_blocks:
                            if remaining_first_hour > pd.Timedelta(0):
                                take = min(block, remaining_first_hour)
                                if is_nd:
                                    ord_nd_ot += take
                                else:
                                    ord_ot += take
                                remaining_first_hour -= take
                                block -= take

                            full_chunks = block // pd.Timedelta(minutes=30)
                            if full_chunks > 0:
                                take = full_chunks * pd.Timedelta(minutes=30)
                                if is_nd:
                                    ord_nd_ot += take
                                else:
                                    ord_ot += take

                    # logging.info(f"DEBUG running totals -> ord_ot: {ord_ot}, ord_nd: {ord_nd}, ord_nd_ot: {ord_nd_ot}, ot_blocks_count: {len(ot_blocks)}")
                    logging.info("Info5")
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

                        logging.info(f"15-24 Final OT record_date {record_date} earliest{earliest_time} and latest{latest_time}: ord_ot={ord_ot}, ord_nd_ot={ord_nd_ot}, ord_nd={ord_nd} ")
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

                    if row["department"].lower() != "security":
                        log_dtr_db(conn, row, "ord_ot",ord_ot, biometric_imports_id, custom_dates_df)
                        log_dtr_db(conn, row, "ord_nd",ord_nd, biometric_imports_id, custom_dates_df)
                        log_dtr_db(conn, row, "ord_nd_ot",ord_nd_ot, biometric_imports_id, custom_dates_df)
                    elif row["department"].lower() == "security":
                        # Define time thresholds
                        t_7am = pd.Timedelta(hours=7)
                        t_715am = pd.Timedelta(hours=7, minutes=15)
                        t_7pm = pd.Timedelta(hours=19)
                        t_715pm = pd.Timedelta(hours=19, minutes=15)
                        t_7am_next = pd.Timedelta(hours=31)  # 07:00 next day

                        ## CHECKZ
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
                        # --- Log to both DBs ---
                        log_security_db(conn, row, "OT", ord_ot_val)
                        log_security_db(conn, row, "ND", ord_nd_val + ord_nd_ot_val)
                        # ✅ Do NOT return any values for security
                        # return
                    logging.info("Info6")
                return [
                    round(ord_ot.total_seconds() / 3600, 2),
                    round(ord_nd.total_seconds() / 3600, 2),
                    round(ord_nd_ot.total_seconds() / 3600, 2),
                ]

            except Exception as ex:
                logging.info(f"error calculating ORD: {ex}")
                return [0, 0, 0]
        
        
     
        def calculate_rd_overtime(row):
            try:
                # 1) Identify date & skip if not a rest‐day
                # last_name = str(row.get("last_name") or row.get("Last Name") or "").strip()
                # first_name = str(row.get("first_name") or row.get("First Name") or "").strip()
                employee_name = str(row.get("employee_name")).strip()
              
                record_date = str(row["record_date"]).split(" ")[0]

                temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)
              

                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
                
                
                if record_date not in cleaned_non_working_days:
                    return [0, 0, 0]
                earliest_time = row["earliest_time"]  # Timedelta since midnight
                latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
                if earliest_time == latest_time:
                    return [0, 0, 0]
                
                # --- Skip if marked as leave in attendance_records ---
                if row.get("leaves"):
                    logging.info(f"Leave marked for employee {row.get('employee_management_id')} on {record_date}. Skipping hours calculation.")
                    return [0, 0, 0]
                
             
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        SELECT type, employee_name, record_date, earliest_time, latest_time
                        FROM overtimes
                        WHERE type = %s
                        AND employee_name = %s
                        AND TO_CHAR(record_date, 'YYYY-MM-DD') = %s
                        AND status = 'Approved'
                        LIMIT 1;
                        """,
                        (
                            "RD",
                            employee_name,
                            record_date,
                        ),
                    )
                    employee_record = cur.fetchone()
                if not employee_record:
                    # Not in employee_dates_list → skip
                    #logging.info("Not In Employee")
                    return [0, 0, 0]

                # If found, use times from employee record
                if employee_record:
                    # Replace earliest/latest with record values
                    earliest_time = pd.to_timedelta(employee_record[3])
                    latest_time = pd.to_timedelta(employee_record[4])

               

                # 2) Build actual in/out datetimes from the row’s punches
                # in_td   = row["Earliest Time"]
                # out_td  = row.get("Latest Time", pd.to_timedelta("00:00:00"))
                # date_base = pd.to_datetime(record_date, format="%Y-%m-%d")
                # in_time   = date_base + in_td
                # out_time  = date_base + out_td
                
                #2) Build actual in/out datetimes
                # in_td   = row["earliest_time"]
                # out_td  = row.get("latest_time", pd.to_timedelta("00:00:00"))
                in_td = earliest_time
                out_td = latest_time
                date_base = pd.to_datetime(record_date,errors="coerce")
                in_time   = date_base + in_td
                out_time  = date_base + out_td

                # 3) Validate & handle cross‐midnight
                if in_time == out_time:
                    return [0, 0, 0]
                if out_time <= in_time:
                    out_time += pd.Timedelta(days=1)
                # Build the combined name
                # employee_name = f"{last_name}, {first_name}"
                # print(f"RD OT DEBUG] {employee_name} | IN: {in_time} | OUT: {out_time}")


                # First look in temp schedule for that person/date
                temp_match = temp_sched_pd[
                    (temp_sched_pd["employee_name"] == employee_name) &
                    (temp_sched_pd["record_date"] == record_date)
                ]

                if not temp_match.empty:
                    # use temp schedule
                    schedule = temp_match.iloc[0]["schedule"]
                else:
                    # fall back to the normal schedule table
                    match = data[data["employee_name"] == employee_name]
                    if match.empty:
                        return 0.0
                    schedule = match.iloc[0]["schedule"].strip()
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
                

               

               # Assume: schedule already determined
                day_shift = schedule in ("7-16", "8-17", "7-19","6-15","9-15","10-18","10-16")
                night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")
                
                # 4) Prepare counters and thresholds
                rd_nd     = pd.Timedelta(0)
                rd_ot     = pd.Timedelta(0)
                rd_nd_ot  = pd.Timedelta(0)
                worked    = pd.Timedelta(0)

                nd_start   = pd.to_timedelta("22:00:00")
                nd_end     = pd.to_timedelta("06:00:00")
                base_hours = pd.to_timedelta("09:00:00")
                if schedule in ("15-23","23-7"):
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
                        #print(f"nNight shift detected at {current} | Block: {block} | Worked so far: {worked}")

                        # For no employee record, we still process all blocks but adjust ND calculation

                        if worked < base_hours:
                            remaining_base = base_hours - worked
                            #print(f"emaining base hours: {remaining_base}")

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
                            if not employee_record:
                                schedule_start_hour = schedule.split("-")[0]
                                schedule_start_td = pd.to_timedelta(f"{schedule_start_hour}:00:00")
                                # For night shifts, handle midnight crossover properly
                                if schedule_start_hour in ["18", "19", "20", "21", "22", "23"]:
                                    # Night shift: only count ND if current time is after schedule start
                                    # Handle midnight crossover: times 00:00-06:00 are considered after 23:00
                                    if tod_td >= schedule_start_td or tod_td < pd.to_timedelta("06:00:00"):
                                        pass  # Keep is_nd as is
                                    else:
                                        is_nd = False
                                else:
                                    # Day shift: normal comparison
                                    is_nd = is_nd and (tod_td >= schedule_start_td)
                            
                            # If this block is ND, the entire block is ND
                            if is_nd:
                                nd_block = block
                            else:
                                nd_block = pd.Timedelta(0)

                            # print(f"aw ND block: {nd_block}")
                            # print(f"urrent time: {current}, Block size: {block}, Is ND: {is_nd}")

                            # cap ND to remaining base
                            nd_block = min(nd_block, remaining_base)
                            worked_block = min(block, remaining_base)
                            worked += worked_block

                            # print(f"orked block (base): {worked_block}, ND portion: {nd_block}")
                            # print(f"otal ND so far: {ord_nd}")

                            # split base into ND and non-ND
                            rd_nd += nd_block
                            non_nd_base = worked_block - nd_block
                            if non_nd_base > pd.Timedelta(0):
                                pass
                                #print(f"on-ND base portion: {non_nd_base}")

                            # remainder becomes OT
                            second_part = block - worked_block
                            if second_part > pd.Timedelta(0):
                                # print(f"emainder (possible OT): {second_part}")
                                if employee_record:
                                    ot_blocks.append((second_part, is_nd))
                                    #print(f"  Added OT block: {second_part}, ND={is_nd}")
                                else:
                                    pass
                                    #print("   Skipping OT (not in employee record)")
                        else:
                            #print(f"ase hours already met. Entire block considered OT: {block}")
                            if employee_record:
                                ot_blocks.append((block, is_nd))
                                # print(f"  Added OT block: {block}, ND={is_nd}")
                            else:
                                pass
                                #print("   Skipping OT (not in employee record)")

                    current = next_hour

                    # --- OT Handling ---
                    ot_total = sum((b for b, _ in ot_blocks), pd.Timedelta(0))
                    #print(f"nTotal OT accumulated: {ot_total}")

                    if ot_total >= pd.Timedelta(hours=1):
                        remaining_first_hour = pd.Timedelta(hours=1)

                        for block, is_nd in ot_blocks:
                            # print(f"rocessing OT block: {block}, ND={is_nd}")

                            # take from first OT hour
                            if remaining_first_hour > pd.Timedelta(0):
                                take = min(block, remaining_first_hour)
                                if is_nd:
                                    rd_nd_ot += take
                                    # print(f"  Counted ND OT (first hour): {take}")
                                    # print(f"  Total ND OT so far: {ord_nd_ot}")
                                else:
                                    rd_ot += take
                                    #print(f"  Counted OT (first hour): {take}")
                                remaining_first_hour -= take
                                block -= take

                            # after first hour: only full ≥30min chunks count
                            full_chunks = block // pd.Timedelta(minutes=30)
                            if full_chunks > 0:
                                take = full_chunks * pd.Timedelta(minutes=30)
                                if is_nd:
                                    rd_nd_ot += take
                                    # print(f"  Counted ND OT chunks: {take}")
                                    # print(f"  Total ND OT so far: {ord_nd_ot}")
                                else:
                                    rd_ot += take
                                    #print(f"  Counted OT chunks: {take}")
                            else:
                                if block > pd.Timedelta(0):
                                    pass
                                    #print(f"  Ignored leftover OT under 30m: {block}")
                    else:
                        pass
                        #print("Total OT less than 1h → ignored")


                #print("before",rd_nd)
                # if 23-8 minus 1 hr for lunch in rd_nd
                if schedule.strip() in ["23-8"]:
                    rd_nd = rd_nd - pd.Timedelta(hours=1)
                    #print("after",rd_nd)
                    
    

                logging.info(f"RD OT DEBUG] {employee_name} | IN: {in_time} | OUT: {out_time} | RD ND {rd_nd} RD OT {rd_ot} RD ND OT {rd_nd_ot}")
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
                        nd_overlap_1 = max(pd.Timedelta(0),min(latest_time, pd.to_timedelta("24:00:00")) - max(earliest_time, nd_start))
                        rd_nd += nd_overlap_1

                        # --- Calculate ND past midnight (00:00–06:00) ---
                        nd_overlap_2 = max(pd.Timedelta(0),min(latest_time - pd.Timedelta(days=1), nd_end) - pd.Timedelta(0))

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

                    logging.info(f"{schedule} OT: rd_ot={rd_ot}, rd_nd_ot={rd_nd_ot}")


                logging.info(
                    f"rd_ot={rd_ot.total_seconds()}, "
                    f"rd_nd={rd_nd.total_seconds()}, "
                    f"rd_nd_ot={rd_nd_ot.total_seconds()}, "
                    f"condition={(rd_ot.total_seconds() <= 0 and rd_nd.total_seconds() <= 0 and rd_nd_ot.total_seconds() <= 0)}"
                )
                if row["department"].lower() != "security":
                        log_dtr_db(conn, row, "rd_ot",rd_ot, biometric_imports_id, custom_dates_df)
                        log_dtr_db(conn, row, "rd_nd",rd_nd, biometric_imports_id, custom_dates_df)
                        log_dtr_db(conn, row, "rd_nd_ot",rd_nd_ot, biometric_imports_id, custom_dates_df)
                elif row["department"].lower() == "security":
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
                        rd_ot_variable = rd_ot_val
                        log_security_db(conn, row, "ND", rd_nd_val + rd_nd_ot_val)

                        # ✅ Do NOT return any values for security
                        # return

                # 7) Return [RD-OT, RD-ND, RD-ND-OT] as floats
                return [
                    round(rd_ot.total_seconds() / 3600, 2),
                    round(rd_nd.total_seconds() / 3600, 2),
                    round(rd_nd_ot.total_seconds() / 3600, 2),
                ]

            except Exception as ex:
                logging.info(f"error calculating RD overtime: {ex}")
                return [0, 0, 0]


        def compute_rd(row, data):
            try:
                # 🔹 Recreate employee match here
                
                employee_name = str(row.get("employee_name")).strip()
                #record_date = str(row.get("record_date") or "").replace("'", "").strip()
                # 1) Pull & clean the record date
                record_date = str(row["record_date"]).split(" ")[0]
                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
                
                # 2) Only compute on true rest-days
                if record_date not in cleaned_non_working_days:
                    return 0.0

                if row.get("leaves"):
                    logging.info(f"Leave marked for employee {row.get('employee_management_id')} on {record_date}. Skipping hours calculation.")
                    return 0.0


                #temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments", engine)
                temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)



               

                match = data[data["employee_name"] == employee_name]
                if match.empty:
                    return 0.0
              
               
                
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        SELECT type, employee_name, record_date, earliest_time, latest_time
                        FROM overtimes
                        WHERE type = %s
                        AND employee_name = %s
                        AND TO_CHAR(record_date, 'YYYY-MM-DD') = %s
                        AND status = 'Approved'
                        LIMIT 1;
                        """,
                        (
                            "RD", 
                            employee_name,
                            record_date,
                        ),
                    )
                    employee_record = cur.fetchone()

                
                if not employee_record:
                    # 🚫 Not in employee_dates_list → skip
                    logging.info("Not in employee")
                    return 0.0
                
                earliest_time = row["earliest_time"]  # Timedelta since midnight
                latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
                if earliest_time == latest_time:
                    return 0.0
                

                # ✅ If found, use times from employee record
                if employee_record:
                    # Replace earliest/latest with record values
                    earliest_time = pd.to_timedelta(employee_record[3])
                    latest_time = pd.to_timedelta(employee_record[4])
                
                logging.info(f"DEBUG] Processing RD | Name: {employee_name} | Record Date: {record_date}")
                
                schedule = match.iloc[0]["schedule"].strip()
                # First look in temp schedule for that person/date
                temp_match = temp_sched_pd[
                    (temp_sched_pd["employee_name"] == employee_name) &
                    (temp_sched_pd["record_date"] == record_date)
                ]
               
             

                if not temp_match.empty:
                    # use temp schedule
                    schedule = temp_match.iloc[0]["schedule"]
                else:
                    # fall back to the normal schedule table
                    match = data[data["employee_name"] == employee_name]
                    if match.empty:
                        return 0.0
                    schedule = match.iloc[0]["schedule"]
               
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


               
               
                
                day_shift = schedule in ("7-16", "8-17", "7-19","6-15","9-15","10-18","10-16")
                night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")
                # 3) Parse raw punches into timestamps
                in_td  = pd.to_timedelta(row["earliest_time"], errors="coerce")
                out_td = pd.to_timedelta(row.get("latest_time", "00:00:00"), errors="coerce")
                if pd.isna(in_td) or pd.isna(out_td):
                    return 0.0
                
                # date_base = pd.to_datetime(record_date, format="%Y-%m-%d", errors="coerce")
                # in_time   = date_base + in_td
                # out_time  = date_base + out_td

                date_base = pd.to_datetime(record_date, format="%Y-%m-%d", errors="coerce")
                in_time   = date_base + earliest_time   # ← use overridden earliest_time
                out_time  = date_base + latest_time     # ← use overridden latest_time
                
                # 6) Round up all lates
                late_threshold = date_base + late_cutoff
                if in_time > late_threshold:
                    delta = in_time - late_threshold
                    if delta < pd.Timedelta(hours=1):
                        in_time = in_time.floor("h") + pd.Timedelta(hours=1)

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
                if schedule in ("15-23","23-7","9-15"):
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
                if schedule.strip() not in ["15-23", "23-7","23-8"]:
                    post_lunch = non_nd_base_time - pd.Timedelta(hours=1)
                else:
                    post_lunch = non_nd_base_time

                if post_lunch <= pd.Timedelta(0):
                    hours = 0.0
                else:
                    # 8) Cap at 8 h
                    worked = min(post_lunch, pd.Timedelta("8:00:00"))
                    hours  = round(worked.total_seconds() / 3600, 2)
                
            
                # if hours > 0:
                #     log_overtime_to_json(
                #         row,
                #         ord_ot=0, rd_ot=0,
                #         ord_nd=0, ord_nd_ot=0,
                #         rd_nd=0, rd_nd_ot=0,
                #         rd=hours,
                #         total_non_working_days_present=0,
                #         late=False, late_hours=0, late_minutes=0,
                #         out_time_required=None,
                #         type="RD",
                #     )
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
                if row["department"].lower() != "security":
                        log_dtr_db(conn, row, "rd",hours, biometric_imports_id, custom_dates_df)
                elif row["department"].lower() == "security":
                        # --- Security: RD logging with computation like ORD ---
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

                        # Initialize RD values
                        rd_val = 0.0
                        rd_nd_val = 0.0
                        rd_nd_ot_val = 0.0

                        if diff_7am <= diff_7pm:
                            # --- Day shift (7–19) ---
                            if earliest_time <= t_715am and latest_time >= t_7pm:
                                # Within expected range → fixed RD OT
                                rd_val = 4.0
                                logging.info(f"Security (day shift) fixed RD = {rd_val}")
                            else:
                                # Compute actual worked hours
                                worked_hours = (latest_time - earliest_time).total_seconds() / 3600
                                rd_val = max(0, round(worked_hours - 8, 2))
                                logging.info(f"Security (day shift manual) worked={worked_hours:.2f} hrs, RD={rd_val}")
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
                        # --- Log to both DBs ---
                        all_rd = rd_ot_variable + rd_val
                        log_security_db(conn, row, "OT", all_rd)
                        
                        # ✅ Do NOT return any values for security
                        # return

                return hours

            except Exception as e:
                print(f"Error auto-computing RD hours: {e}")
                return 0.0
        
        # print(15555)


        df[["Ord-OT", "Ord-ND", "Ord-ND-OT"]] = df.apply(calculate_ord, axis=1, result_type="expand")
        print("ord done")
        # added because hours is being added to hours worked
        #df["Hours Worked"] = df["Hours Worked"] - df["Ord-OT"] -  df["Ord-ND"]  - df["Ord-ND-OT"] 
        df["Hours Worked"] = df["Hours Worked"] - df["Ord-OT"] - df["Ord-ND-OT"]        

        #print("ORD OT Flag")
        df[["RD-OT", "RD-ND", "RD-ND-OT"]] = df.apply(calculate_rd_overtime, axis=1, result_type="expand")
        print("rd ot done")
        #added because hours is being added to hours worked
        #df["Hours Worked"] = df["Hours Worked"] - df["RD-OT"] -  df["RD-ND"]  - df["RD-ND-OT"] 
        # df["Hours Worked"] = df["Hours Worked"] - df["RD-OT"]  - df["RD-ND-OT"]
        #print(df["Hours Worked"])
      
        
        
        df["RD"] = df.apply(compute_rd, axis=1, args=(data,))
        print("rd done")
        #added because hours is being added to hours worked
        # If there is RD overtime, remove the base 8 hours that were counted in Hours Worked
        rd_ot_mask = (df["RD-ND"] > 0) | (df["RD-ND-OT"] > 0)
        if rd_ot_mask.any():
            df.loc[rd_ot_mask, "Hours Worked"] = (df.loc[rd_ot_mask, "Hours Worked"] - 8).clip(lower=0)
        #print(df["Hours Worked"])
        #print(df["RD"])
        #df["Hours Worked"] = df["Hours Worked"] - df["RD"]
        # df["Total Non-Working Days Present"] = df.apply(
        #     lambda row: (
        #         1  # Add 1 if the conditions below are met
        #         if any(
        #             emp[1] == row["Last Name"]  # The last name matches
        #             and emp[2] == row["First Name"]  # The first name matches
        #             and emp[3] == row["Record Date"].replace("'", "").strip()  # The record date matches
        #             and emp[0] == "RD"  # emp[0] equals "RD"
        #             for emp in employee_dates_list  # Iterate through employee_dates_list
        #         )
        #         or row["Record Date"].replace("'", "").strip()
        #         in custom_dates_list  # Or the record date is in custom_dates_list
        #         else 0  # If neither condition is met, assign 0
        #     ),
        #     axis=1,  # Apply row by row
        # )
        # df["Total Non-Working Days Present"] = df.apply(
        #     lambda row: (
        #         1
        #         if any(
        #             emp[1] == row["Last Name"]  # Last name matches
        #             and emp[2] == row["First Name"]  # First name matches
        #             and (
        #                 # normalize emp[3] like in employee_record
        #                 (
        #                     emp[3].replace("'", "").strip()
        #                     if len(emp[3].split("/")) != 3
        #                     else f"{emp[3].split('/')[2]}-{emp[3].split('/')[0].zfill(2)}-{emp[3].split('/')[1].zfill(2)}"
        #                 )
        #                 == row["Record Date"].replace("'", "").strip()
        #             )
        #             and emp[0] == "RD"
        #             for emp in employee_dates_list
        #         )
        #         or row["Record Date"].replace("'", "").strip() in custom_dates_list
        #         else 0
        #     ),
        #     axis=1,
        # )
        

        #print(22222)
        


        return df

    except Exception as ex:
        print(f"rror calculating hours worked: {ex}")


def group_employee_data(df):
    """Groups the employee data and calculates required fields."""
    try:
        # current_year = datetime.datetime.now().year
        # last_year = current_year - 1
        # # Get Sundays for the current year and last year, then combine them
        # sundays_current_year = get_sundays(current_year)
        # sundays_last_year = get_sundays(last_year)
        # sundays = sundays_last_year + sundays_current_year  # Combine lists

        # # logging.info(sundays)

        # # logging.info(custom_dates_list)

        # # All dates should be in yyyy-mm-dd format
        # non_working_days = calculate_total_non_workingdays(current_year, None)
        # non_working_days += sundays
        # non_working_days += custom_dates_list
        
        # # Ensure all dates in non_working_days are in YYYY-MM-DD format
        # formatted_non_working_days = []
        # for date_str in non_working_days:
        #     try:
        #         # Try to parse the date string and convert to YYYY-MM-DD format
        #         date_obj = datetime.datetime.strptime(date_str, '%m/%d/%Y')
        #         formatted_non_working_days.append(date_obj.strftime('%Y-%m-%d'))
        #     except ValueError:
        #         # If the date is already in YYYY-MM-DD format, keep it as is
        #         formatted_non_working_days.append(date_str)
        
        # non_working_days = formatted_non_working_days
        # #logging.info("ll non-working days in YYYY-MM-DD format:", non_working_days)
        
        # # Convert non_working_days to a set for faster lookups
        # non_working_days_set = set(non_working_days)
        # # Filter out days where 'Hours Worked' is zero or the date is in non_working_days
        custom_dates_df = pd.read_sql("SELECT record_date FROM custom_dates", engine)
        non_working_days = custom_dates_df['record_date'].astype(str).tolist()
        non_working_days_set = set(non_working_days)
        # df["Working Day Count"] = df.apply(
        #     lambda row: (
        #         1
        #         if row["hours_worked"] > 0
        #         and row["record_date"].replace("'", "").strip() not in non_working_days_set
        #         else 0
        #     ),
        #     axis=1,
        # )
        

       # 🔹 Exclude employees from certain departments (e.g. Security)
       # Exclude the Security department
        df = df[df["department"].str.lower() != "security"]
        #logging.info(2)
        #logging.info(df.columns.tolist())
        df_grouped = (
            df.groupby("employee_name")
            .agg(
                # ID=("ID", "first"),
                # Basic=("Basic", "first"),
                unique_id=("unique_id", "first"),
                basic_salary=("basic_salary", "first"),
                Hours_Worked=("Hours Worked", "sum"),
                Ord_OT=("Ord-OT", "sum"),
                RD=("RD", "sum"),
                RD_OT=("RD-OT", "sum"),
                RD_ND=("RD-ND", "sum"),
                RD_ND_OT=("RD-ND-OT", "sum"),
                Ord_ND=("Ord-ND", "sum"),
                Ord_ND_OT=("Ord-ND-OT", "sum"),
                RegNDExcess=("RegNDExcess", "sum"),
                # Total_Regular_Working_Days_Present=("Working Day Count", "sum"),
                # Total_Non_Working_Days_Present=("Total Non-Working Days Present", "sum"),
            )
            .reset_index()
        )
        #logging.info(1)
        # Ordinary OT → HH:MM
        df_grouped["Ord_OT"] = df_grouped["Ord_OT"].apply(
            lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        )
        # Rest-day  → HH:MM
        df_grouped["RD"] = df_grouped["RD"].apply(
            lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        )

        # Rest-day OT → HH:MM
        df_grouped["RD_OT"] = df_grouped["RD_OT"].apply(
            lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        )

        # Rest-day ND → HH:MM
        df_grouped["RD_ND"] = df_grouped["RD_ND"].apply(
            lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        )

        # Rest-day ND-OT → HH:MM
        df_grouped["RD_ND_OT"] = df_grouped["RD_ND_OT"].apply(
            lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        )

        # Ordinary ND → HH:MM
        df_grouped["Ord_ND"] = df_grouped["Ord_ND"].apply(
            lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        )

        # Ordinary ND-OT → HH:MM
        df_grouped["Ord_ND_OT"] = df_grouped["Ord_ND_OT"].apply(
            lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        )

        # Excess ND beyond reg hours → HH:MM
        df_grouped["RegNDExcess"] = df_grouped["RegNDExcess"].apply(
            lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        )

        # # Total Hours Worked → HH:MM
        # df_grouped["Hours_Worked"] = df_grouped["Hours_Worked"].apply(
        #     lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        # )
        # Round 'Hours_Worked' to nearest int
        df_grouped["Hours_Worked"] = df_grouped["Hours_Worked"].apply(
            lambda x: int(round(x))
        )

        

        return df_grouped

    except Exception as ex:
        logging.info(f"Error grouping employee data: {ex}")
        return df  # Return the original DataFrame in case of error


def prepare_excel(df_grouped, output_excel_file):
    """Prepares the final DataFrame for Excel output with formatted text, borders, wrap, and alignment."""
    try:
        df_grouped = df_grouped.rename(columns={"unique_id": "ID", "basic_salary": "Basic", "employee_name": "Name"})
        headers = [
            "ID", "Name", "Basic", "Hours_Worked",
            "Total_Regular_Working_Days_Present", "Total_Non_Working_Days_Present",
            "Ord_OT", "Ord_ND", "Ord_ND_OT", "RegNDExcess",
            "RD", "RD_OT", "RD_ND", "RD_ND_OT", "SunNDExcess",
            "SH", "SH-OT", "SH-ND", "SH-ND-OT", "SHNDExcess",
            "LH", "LH-OT", "LH-ND", "LH-ND-OT", "LHNDExcess",
            "SH-RD", "SH-RD-OT", "SH-RD-ND", "SH-RD-ND-OT", "SHRNDExcess",
            "LH-RD", "LH-RD-OT", "LH-RD-ND", "LH-RD-ND-OT", "LHRNDExcess",
            "DH", "DH-OT", "DH-ND", "DH-ND-OT", "DHNDExcess",
            "DH-RD", "DH-RD-OT", "DH-RD-ND", "DH-RD-ND-OT",
        ]

        for h in headers:
            if h not in df_grouped.columns:
                df_grouped[h] = ""

        df_grouped = df_grouped.reindex(columns=headers)
        df_grouped = df_grouped.fillna("").astype(str)
        

        formatted = [h.replace("_", "-") for h in headers]
        rename = {
            "Total-Regular-Working-Days-Present": "Total Regular Working Days Present",
            "Total-Non-Working-Days-Present": "Total Non-Working Days Present",
            "Hours-Worked": "Hours Worked"
        }
        final_headers = [rename.get(h, h) for h in formatted]

        df_grouped.to_excel(output_excel_file, index=False, header=final_headers)

        wb = load_workbook(output_excel_file)
        ws = wb.active

        ws.auto_filter.ref = ws.dimensions

        font = Font(name="Arial", size=10)
        header_alignment = Alignment(vertical="top", wrap_text=True)
        cell_alignment = Alignment(horizontal="left", vertical="center", wrap_text=True)

        # Border styles
        light_gray_side = Side(style="thin", color="D3D3D3")  # light gray for top/left/right
        gray_bottom_side = Side(style="thin", color="9B9B9B")  # darker gray for bottom border
        header_border = Border(
            top=light_gray_side,
            bottom=gray_bottom_side,
            left=light_gray_side,
            right=light_gray_side
        )

        # Right border for "Basic" column
        basic_right_side = Side(style="thin", color="9B9B9B")
        basic_right_border = Border(right=basic_right_side)

        ws.row_dimensions[1].height = 63.75

        # Format headers with borders and alignment
        for cell in ws[1]:
            cell.number_format = "@"
            cell.font = font
            cell.alignment = header_alignment
            cell.border = header_border
            cell.value = str(cell.value or "")

        # Identify column index for "Basic"
        basic_index = final_headers.index("Basic") + 1

        # Format data rows
        for row in ws.iter_rows(min_row=2, max_row=ws.max_row, max_col=ws.max_column):
            for cell in row:
                cell.number_format = "@"
                cell.font = font
                cell.alignment = cell_alignment

                if cell.column == basic_index:
                    cell.border = basic_right_border

                cell.value = str(cell.value or "")

        # Set column widths
        for idx, header in enumerate(headers, start=1):
            letter = get_column_letter(idx)
            if header == "ID":
                ws.column_dimensions[letter].width = 17.86
            elif header == "Name":
                ws.column_dimensions[letter].width = 47.86
            elif header == "Basic":
                ws.column_dimensions[letter].width = 11.86
            else:
                ws.column_dimensions[letter].width = 8

        wb.save(output_excel_file)

    except Exception as ex:
        print(f"rror preparing Excel output: {ex}")



def prepare_csv(df_grouped, output_csv_file):
    """Prepares the final DataFrame for CSV output with formatted headers."""
    try:
        headers = [
            "ID",
            "Name",
            "Basic",
            "Hours Worked",
            "Total Regular Working Days Present",
            "Total Non Working Days Present",
            "Ord OT",
            "Ord ND",
            "Ord ND OT",
            "Reg ND Excess",
            "RD",
            "RD OT",
            "RD ND",
            "RD ND OT",
            "Sun ND Excess",
            "SH",
            "SH OT",
            "SH ND",
            "SH ND OT",
            "SH ND Excess",
            "LH",
            "LH OT",
            "LH ND",
            "LH ND OT",
            "LH ND Excess",
            "SH RD",
            "SH RD OT",
            "SH RD ND",
            "SH RD ND OT",
            "SH RD ND Excess",
            "LH RD",
            "LH RD OT",
            "LH RD ND",
            "LH RD ND OT",
            "LH RD ND Excess",
            "DH",
            "DH OT",
            "DH ND",
            "DH ND OT",
            "DH ND Excess",
            "DH RD",
            "DH RD OT",
            "DH RD ND",
            "DH RD ND OT",
        ]

        # Ensure all headers are present in DataFrame
        for header in headers:
            if header not in df_grouped.columns:
                df_grouped[header] = None

        # Reorder columns to match the headers
        df_grouped = df_grouped.reindex(columns=headers)

        # Write to CSV
        df_grouped.to_csv(output_csv_file, index=False)

    except Exception as ex:
        print(f"rror preparing CSV output: {ex}")


def excel_to_csv(input_excel_file, output_csv_file, sheet_name=0):
    """
    Converts a specified sheet in an Excel file to a CSV file with UTF-8 encoding without modifying the original Excel file.

    Parameters:
        input_excel_file (str): Path to the input Excel file.
        output_csv_file (str): Path to save the output CSV file.
        sheet_name (str or int): The sheet name or index to convert. Default is the first sheet (index 0).
    """
    try:
        # Read the specified sheet from the Excel file into a DataFrame
        df = pd.read_excel(input_excel_file, sheet_name=sheet_name, engine="openpyxl")

        # Save the DataFrame to a CSV file with UTF-8 encoding
        df.to_csv(output_csv_file, index=False, encoding="utf-8-sig")

        # print(
        #     f"Successfully converted '{input_excel_file}' (sheet '{sheet_name}') to '{output_csv_file}' with UTF-8 encoding."
        # )
    except Exception as ex:
        print(f"Error converting Excel to CSV: {ex}")


def security_report_generate(output_file_path, logo_path, engine):
    """
    Generates a duty summary Excel for security attendance,
    matching the VESTA format (with day shift, relievers, night shift, relievers).
    """
    try:
       

        # ===== QUERY SECURITY ATTENDANCE =====
        query = """
            SELECT sa.employee_management_id,
                em.employee_name,
                em.department,
                em.schedule_shift,
                em.relievers,
                sa.record_date,
                sa.hours_worked,
                sa.earliest_time,
                sa.latest_time,
                sa.ot,
                sa.nd
            FROM security_attendance sa
            INNER JOIN employee_management em
            ON sa.employee_management_id = em.id
            ORDER BY sa.record_date, em.department, em.employee_name;
        """
        df = pd.read_sql(query, engine)
        if df.empty:
            logging.info("No security attendance data found.")
            return

        # ===== SPLIT DATA =====
        df_day = df[df["schedule_shift"].str.contains("DAY", case=False, na=False)]
        df_night = df[df["schedule_shift"].str.contains("NIGHT", case=False, na=False)]

        day_guards = df_day[df_day["relievers"] == False][["employee_management_id", "employee_name"]].drop_duplicates()
        day_relievers = df_day[df_day["relievers"] == True][["employee_management_id", "employee_name"]].drop_duplicates()
        night_guards = df_night[df_night["relievers"] == False][["employee_management_id", "employee_name"]].drop_duplicates()
        night_relievers = df_night[df_night["relievers"] == True][["employee_management_id", "employee_name"]].drop_duplicates()

        # ===== EXCEL SETUP =====
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Dayshift"

        # ===== HEADER IMAGE =====
        try:
            img = Image(logo_path)
            img.width = 27.9 * 37.7952755906
            img.height = 3.73 * 37.7952755906
            img.anchor = "D1"
            ws.add_image(img)
        except Exception as e:
            logging.warning(f"Could not insert logo: {e}")

        # ===== HEADER TITLE =====
        start_date = pd.to_datetime(df_day["record_date"].min())
        end_date = pd.to_datetime(df_day["record_date"].max())
        if pd.notna(start_date) and pd.notna(end_date):
            title = f"DUTY SUMMARY FOR THE MONTH OF {start_date.strftime('%B %d')}-{end_date.strftime('%d, %Y')}"
        else:
            title = "DUTY SUMMARY"
        ws.merge_cells("A8:U8")
        ws["A8"] = title
        ws["A8"].alignment = Alignment(horizontal="center")
        ws["A8"].font = Font(size=14, bold=True)

        # ===== HEADER COLUMNS =====
        days = pd.date_range(start=start_date, end=end_date)
        headers = ["#", "DAY SHIFT"] + [d.strftime("%d") for d in days] + [
            "TOTAL DAYS", "REG", "OT", "TOTAL HRS", "SIGNATURE"
        ]
        ws.append(headers)
        ws.row_dimensions[9].height = 41
        ws.column_dimensions['B'].width = 260 / 7
        for col in range(1, len(headers) + 1):
            cell = ws.cell(row=9, column=col)
            cell.font = Font(bold=True)
            cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        ws["R9"].alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        ws["U9"].alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        ws["V9"].alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)

        thin = Side(border_style="thin", color="000000")

        # ===== DAY SHIFT GUARDS =====
        for i, emp in enumerate(day_guards.itertuples(), start=1):
            emp_df = df_day[df_day["employee_management_id"] == emp.employee_management_id]

            logging.info(f"\nProcessing employee: {emp.employee_name} (ID: {emp.employee_management_id})")
            logging.info(f"  Records for this employee: {len(emp_df)}")

            # ✅ Aggregate by record_date to avoid double counting
            daily_df = emp_df.groupby("record_date", as_index=False).agg({
                "hours_worked": "sum",
                "ot": "sum",
                "nd": "sum"
            })
            logging.info(f"  Aggregated days count: {len(daily_df)}")

            

            row = [i, emp.employee_name]
            for d in days:
                record = daily_df[daily_df["record_date"] == d]
                row.append(int(record.iloc[0]["hours_worked"]) if not record.empty else "")

            total_days = len(daily_df["record_date"].unique())
            total_reg = emp_df["hours_worked"].astype(float).sum()
            total_ot = emp_df["ot"].astype(float).sum() + emp_df["nd"].astype(float).sum()
            total_hrs = total_reg + total_ot

            logging.info(f"  total_days={total_days}, total_reg={total_reg}, total_ot={total_ot}, total_hrs={total_hrs}")
            row += [total_days, total_reg, total_ot, total_hrs, ""]
            ws.append(row)

        # ===== DAY RELIEVERS =====
        ws.append([])
        ws.append(["", "DAY SHIFT RELIEVERS"])
        # Get the row index where the title was added
        reliever_row = ws.max_row

        # Style the cell (column B)
        cell = ws[f"B{reliever_row}"]
        cell.font = Font(bold=True, color="000000")  # black text
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.fill = PatternFill(start_color="FFFF00", end_color="FFFF00", fill_type="solid")  # yellow background
        for i, emp in enumerate(day_relievers.itertuples(), start=1):
            emp_df = df_day[df_day["employee_management_id"] == emp.employee_management_id]

            if "earliest_time" in emp_df.columns:
                temp = emp_df.copy()
                temp["earliest_time_hours"] = pd.to_timedelta(temp["earliest_time"], errors="coerce").dt.components["hours"]
                emp_df = temp.loc[temp["earliest_time_hours"] < 15].copy()
                logging.info("Filtered reliever records with earliest_time < 15 hours")
                logging.info("working buddha")

            # ✅ Aggregate by record_date to avoid double counting
            daily_df = emp_df.groupby("record_date", as_index=False).agg({
                "hours_worked": "sum",
                "ot": "sum"
            })

            row = [i, emp.employee_name]
            for d in days:
                record = daily_df[daily_df["record_date"] == d]
                row.append(int(record.iloc[0]["hours_worked"]) if not record.empty else "")

            total_days = len(daily_df["record_date"].unique())
            total_reg = emp_df["hours_worked"].astype(float).sum()
            total_ot = emp_df["ot"].astype(float).sum() + emp_df["nd"].astype(float).sum()
            total_hrs = total_reg + total_ot
            row += [total_days, total_reg, total_ot, total_hrs, ""]
            ws.append(row)

            # now here can you add a row where it will compute the sum of columns per day
            # ===== ADD TOTAL ROW FOR EACH DAY COLUMN =====
            last_row = ws.max_row  # last data row before totals
            total_row = last_row + 1

            ws.cell(row=total_row, column=2).value = "TOTAL"
            ws.cell(row=total_row, column=2).font = Font(bold=True)

            # Loop through all day columns (starting from 3 because col 1 = #, col 2 = name)
            for col_idx in range(3, 3 + len(days)):
                col_letter = get_column_letter(col_idx)
                ws[f"{col_letter}{total_row}"] = f"=SUM({col_letter}10:{col_letter}{last_row})"  # assumes data starts row 10
                ws[f"{col_letter}{total_row}"].font = Font(bold=True)

            # Add total sums for REG, OT, TOTAL HRS columns
            reg_col = get_column_letter(3 + len(days))
            ot_col = get_column_letter(3 + len(days) + 1)
            total_hrs_col = get_column_letter(3 + len(days) + 2)

            ws[f"{reg_col}{total_row}"] = f"=SUM({reg_col}10:{reg_col}{last_row})"
            ws[f"{ot_col}{total_row}"] = f"=SUM({ot_col}10:{ot_col}{last_row})"
            ws[f"{total_hrs_col}{total_row}"] = f"=SUM({total_hrs_col}10:{total_hrs_col}{last_row})"


    
        # ===== BORDERS =====
        for row in ws.iter_rows(min_row=9, max_row=ws.max_row):
            for cell in row:
                cell.border = Border(top=thin, left=thin, right=thin, bottom=thin)
                cell.alignment = Alignment(horizontal="center", vertical="center")

        # ===== SIGNATORIES =====
        ws.append([])  # make sure there’s a blank row first
        last_data_row = ws.max_row
        for _ in range(5):  # add 5 blank rows before signatories
            ws.append([])

        # Titles (row for "PREPARED BY:", "NOTED BY:", etc.)
        ws["B" + str(ws.max_row + 1)] = "PREPARED BY:"
        ws["F" + str(ws.max_row)] = "NOTED BY:"
        ws["M" + str(ws.max_row)] = "CHECKED BY:"
        ws["S" + str(ws.max_row)] = "APPROVED BY:"

        # Blank row for signature line
        ws.append([])

        # Names (each under its column)
        ws["B" + str(ws.max_row + 1)] = "SO KRISTIAN MILLAN"
        ws["F" + str(ws.max_row)] = "SO MAC RENTON MILLAN"
        ws["M" + str(ws.max_row)] = "AMADOR CESARID"
        ws["S" + str(ws.max_row)] = "ENGR. JAY EMMANUEL R. DELGRA"

        # Designations row
        ws.append([])
        ws["B" + str(ws.max_row + 1)] = "ADMIN"
        ws["F" + str(ws.max_row)] = "DETACHMENT COMMANDER"
        ws["M" + str(ws.max_row)] = "SECURITY MANAGER"
        ws["S" + str(ws.max_row)] = "RESIDENT MANAGER"

        # Align signatory text
        for col in ["B", "F", "M", "S"]:
            for r in range(last_data_row + 6, ws.max_row + 1):
                cell = ws[f"{col}{r}"]
                cell.alignment = Alignment(horizontal="center")
                cell.font = Font(bold=True)

        
        
        
        # ===== NIGHT SHIFT SHEET =====
        ws2 = wb.create_sheet(title="Nightshift")

        # ===== HEADER IMAGE =====
        try:
            img = Image(logo_path)
            img.width = 27.9 * 37.7952755906
            img.height = 3.73 * 37.7952755906
            img.anchor = "D1"
            ws2.add_image(img)
        except Exception as e:
            logging.warning(f"Could not insert logo in Nightshift: {e}")

        if df_night.empty:
            logging.info("No nightshift data found — skipping nightshift sheet.")
            return
        # ===== HEADER TITLE =====
        start_date = pd.to_datetime(df_night["record_date"].min())
        end_date = pd.to_datetime(df_night["record_date"].max())
        if pd.notna(start_date) and pd.notna(end_date):
            title = f"DUTY SUMMARY FOR THE MONTH OF {start_date.strftime('%B %d')}-{end_date.strftime('%d, %Y')}"
        else:
            title = "DUTY SUMMARY"
        ws2.merge_cells("A8:U8")
        ws2["A8"] = title
        ws2["A8"].alignment = Alignment(horizontal="center")
        ws2["A8"].font = Font(size=14, bold=True)

        # ===== HEADER COLUMNS =====
        days = pd.date_range(start=start_date, end=end_date)
        headers = ["#", "NIGHT SHIFT"] + [d.strftime("%d") for d in days] + [
            "TOTAL DAYS", "REG", "OT", "TOTAL HRS", "SIGNATURE"
        ]
        ws2.append(headers)
        ws2.row_dimensions[9].height = 41
        ws2.column_dimensions['B'].width = 260 / 7
        for col in range(1, len(headers) + 1):
            cell = ws2.cell(row=9, column=col)
            cell.font = Font(bold=True)
            cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)

        thin = Side(border_style="thin", color="000000")

        # ===== NIGHT SHIFT GUARDS =====
        for i, emp in enumerate(night_guards.itertuples(), start=1):
            emp_df = df_night[df_night["employee_management_id"] == emp.employee_management_id]

            logging.info(f"\nProcessing NIGHT employee: {emp.employee_name} (ID: {emp.employee_management_id})")
            logging.info(f"  Records for this employee: {len(emp_df)}")

            # ✅ Aggregate by record_date to avoid double counting
            daily_df = emp_df.groupby("record_date", as_index=False).agg({
                "hours_worked": "sum",
                "ot": "sum",
                "nd": "sum"
            })

            logging.info(f"  Aggregated days count: {len(daily_df)}")

            row = [i, emp.employee_name]
            for d in days:
                record = daily_df[daily_df["record_date"] == d]
                row.append(int(record.iloc[0]["hours_worked"]) if not record.empty else "")

            total_days = len(daily_df["record_date"].unique())
            total_reg = emp_df["hours_worked"].astype(float).sum()
            total_ot = emp_df["ot"].astype(float).sum() + emp_df["nd"].astype(float).sum()
            total_hrs = total_reg + total_ot

            logging.info(f"  NIGHT total_days={total_days}, total_reg={total_reg}, total_ot={total_ot}, total_hrs={total_hrs}")
            row += [total_days, total_reg, total_ot, total_hrs, ""]
            ws2.append(row)

        

        # ===== DAY RELIEVERS WITH NIGHT SHIFT RELIEF =====
        ws2.append([])
        ws2.append(["", "RELIEVERS"])
        day_reliever_row = ws2.max_row
        cell = ws2[f"B{day_reliever_row}"]
        cell.font = Font(bold=True, color="000000")
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.fill = PatternFill(start_color="FFFF00", end_color="FFFF00", fill_type="solid")  # yellow background

        # Get day relievers who worked night shift relief (earliest_time >= 15 hours)
        day_relievers_night_relief = df_day[df_day["relievers"] == True].copy()
        if not day_relievers_night_relief.empty and "earliest_time" in day_relievers_night_relief.columns:
            temp = day_relievers_night_relief.copy()
            temp["earliest_time_hours"] = pd.to_timedelta(temp["earliest_time"], errors="coerce").dt.components["hours"]
            day_relievers_night_relief = temp.loc[temp["earliest_time_hours"] >= 15].copy()
            logging.info(f"Found {len(day_relievers_night_relief)} day relievers with night shift relief")

        # Group by employee to avoid duplicates
        unique_day_relievers = day_relievers_night_relief[["employee_management_id", "employee_name"]].drop_duplicates()

        for i, emp in enumerate(unique_day_relievers.itertuples(), start=1):
            emp_df = day_relievers_night_relief[day_relievers_night_relief["employee_management_id"] == emp.employee_management_id]

            # ✅ Aggregate by record_date to avoid double counting
            daily_df = emp_df.groupby("record_date", as_index=False).agg({
                "hours_worked": "sum",
                "ot": "sum",
                "nd": "sum"
            })

            row = [i, emp.employee_name]
            for d in days:
                record = daily_df[daily_df["record_date"] == d]
                row.append(int(record.iloc[0]["hours_worked"]) if not record.empty else "")

            total_days = len(daily_df["record_date"].unique())
            total_reg = emp_df["hours_worked"].astype(float).sum()
            total_ot = emp_df["ot"].astype(float).sum() + emp_df["nd"].astype(float).sum()
            total_hrs = total_reg + total_ot

            row += [total_days, total_reg, total_ot, total_hrs, ""]
            ws2.append(row)

        # ===== ADD TOTAL ROW FOR EACH DAY COLUMN =====
        last_row = ws2.max_row
        total_row = last_row + 1
        ws2.cell(row=total_row, column=2).value = "TOTAL"
        ws2.cell(row=total_row, column=2).font = Font(bold=True)

        # Loop through all day columns (starting from 3 because col 1 = #, col 2 = name)
        for col_idx in range(3, 3 + len(days)):
            col_letter = get_column_letter(col_idx)
            ws2[f"{col_letter}{total_row}"] = f"=SUM({col_letter}10:{col_letter}{last_row})"
            ws2[f"{col_letter}{total_row}"].font = Font(bold=True)

        # Add total sums for REG, OT, TOTAL HRS columns
        reg_col = get_column_letter(3 + len(days))
        ot_col = get_column_letter(3 + len(days) + 1)
        total_hrs_col = get_column_letter(3 + len(days) + 2)

        ws2[f"{reg_col}{total_row}"] = f"=SUM({reg_col}10:{reg_col}{last_row})"
        ws2[f"{ot_col}{total_row}"] = f"=SUM({ot_col}10:{ot_col}{last_row})"
        ws2[f"{total_hrs_col}{total_row}"] = f"=SUM({total_hrs_col}10:{total_hrs_col}{last_row})"

        # ===== BORDERS =====
        for row in ws2.iter_rows(min_row=9, max_row=ws2.max_row):
            for cell in row:
                cell.border = Border(top=thin, left=thin, right=thin, bottom=thin)
                cell.alignment = Alignment(horizontal="center", vertical="center")

        # ===== SIGNATORIES =====
        ws2.append([])  # ensure a blank row
        last_data_row = ws2.max_row
        for _ in range(5):
            ws2.append([])

        ws2["B" + str(ws2.max_row + 1)] = "PREPARED BY:"
        ws2["F" + str(ws2.max_row)] = "NOTED BY:"
        ws2["M" + str(ws2.max_row)] = "CHECKED BY:"
        ws2["S" + str(ws2.max_row)] = "APPROVED BY:"

        ws2.append([])

        ws2["B" + str(ws2.max_row + 1)] = "SO KRISTIAN MILLAN"
        ws2["F" + str(ws2.max_row)] = "SO MAC RENTON MILLAN"
        ws2["M" + str(ws2.max_row)] = "AMADOR CESARID"
        ws2["S" + str(ws2.max_row)] = "ENGR. JAY EMMANUEL R. DELGRA"

        ws2.append([])
        ws2["B" + str(ws2.max_row + 1)] = "ADMIN"
        ws2["F" + str(ws2.max_row)] = "DETACHMENT COMMANDER"
        ws2["M" + str(ws2.max_row)] = "SECURITY MANAGER"
        ws2["S" + str(ws2.max_row)] = "RESIDENT MANAGER"

        for col in ["B", "F", "M", "S"]:
            for r in range(last_data_row + 6, ws2.max_row + 1):
                cell = ws2[f"{col}{r}"]
                cell.alignment = Alignment(horizontal="center")
                cell.font = Font(bold=True)
        # ===== SAVE FILE =====
        wb.save(output_file_path)
        logging.info(f"Security duty summary generated at: {output_file_path}")

    except Exception as ex:
        logging.info(f"Error in Security: {ex}")



def report_manual(conn, output_file_path,biometric_imports_id):
    """
    Build manual report using real data from dtr_report table.
    """
    try:
        cur = conn.cursor()

        # --- Load DTR records ---
        cur.execute("""
            SELECT record_date
            FROM dtr_report
            WHERE biometric_imports_id = %s
        """, (biometric_imports_id,))
        rows = cur.fetchall()

        if not rows:
            logging.info(f"No dtr_report rows for biometric_import_id={biometric_imports_id}")
            start_date = end_date = None
        else:
            # Normalize DTR dates to date objects
            dtr_dates = [r[0].date() if hasattr(r[0], "date") else pd.to_datetime(r[0]).date() for r in rows]
            dtr_min = min(dtr_dates)
            dtr_max = max(dtr_dates)

            # Set report range from DTR
            start_date = pd.to_datetime(dtr_min)
            end_date = pd.to_datetime(dtr_max)

            # Ensure range is 16 days
            if (end_date - start_date).days != 16:
                end_date += pd.Timedelta(days=1)
                logging.info(f"Adjusted end_date to {end_date.date()} to ensure 16-day range")

            logging.info(f"DTR range for biometric_import_id={biometric_imports_id}: {dtr_min} -> {dtr_max}")

            # --- Load open certificates (is_cutoff = false) ---
            cur.execute("""
                SELECT date
                FROM certificate_attendance
                WHERE is_cutoff = false AND biometric_imports_id = %s
            """, (biometric_imports_id,))
            cert_rows = cur.fetchall()  # tuples (date,)

            if cert_rows:
                # Normalize certificate dates
                cert_dates = [r[0].date() if hasattr(r[0], "date") else pd.to_datetime(r[0]).date() for r in cert_rows]

                # Check for overlapping certificates
                overlapping = [d for d in cert_dates if d in dtr_dates]
                if overlapping:
                    logging.info(f"Open certificates overlapping DTR dates: {overlapping}")
                else:
                    nearest_cert = min(cert_dates, key=lambda d: min(abs((d - dt).days) for dt in dtr_dates))
                    logging.info(f"No overlapping open certificate — nearest certificate date: {nearest_cert}")

        cur.close()

        # ===== Step 1: Load data from dtr_report =====
        query = """
            SELECT employee_management_id, type, record_date, hours
            FROM dtr_report
            WHERE record_date BETWEEN %s AND %s
            AND biometric_imports_id = %s
            ORDER BY employee_management_id, record_date;
        """
        df = pd.read_sql(query, conn, params=[start_date, end_date, biometric_imports_id])

        if df.empty:
            print("No data found in dtr_report for the given period.")
            return

        # ===== Step 2: Get employee info =====
        emp_query = """
            SELECT id,unique_id, employee_name
            FROM employee_management;
        """
        emp_df = pd.read_sql(emp_query, conn)
        # Ensure both columns have the same type
        df['employee_management_id'] = df['employee_management_id'].astype(int)
        emp_df['id'] = emp_df['id'].astype(int)

        # Merge
        #df = df.merge(emp_df, left_on="employee_management_id", right_on="unique_id", how="left")
        df = df.merge(emp_df, left_on="employee_management_id", right_on="id", how="left")


        # ===== Step 3: Prepare structure =====
        row_types = [
            "Hours Worked","OT (Ordinary day)","SUNDAY Reg 8 hrs","SPECIAL HOL. Reg 8 hrs",
            "SPECIAL HOL. + SUNDAY Reg 8 hrs","LEG. HOLIDAY Reg 8 hrs","LEG. HOLIDAY + SUNDAY Reg 8 hrs",
            "LEG. HOLIDAY + LEG. HOLIDAY Reg 8 hrs","LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY Reg 8 hrs",
            "ND Reg 8 hrs","SUNDAY ND Reg 8 hrs","SPECIAL HOL. ND Reg 8 hrs",
            "SPECIAL HOL. + SUNDAY ND Reg 8 hrs","LEG. HOLIDAY ND Reg 8 hrs","LEG. HOLIDAY + SUNDAY ND Reg 8 hrs",
            "LEG. HOLIDAY + LEG. HOLIDAY ND Reg 8 hrs","LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY ND Reg 8 hrs",
            "EX SUNDAY OT","EX SPECIAL HOL. OT","EX SPECIAL HOL. + SUNDAY OT","EX LEG. HOLIDAY OT",
            "EX. LEG HOLIDAY + SUNDAY OT","EX. LEG. HOLIDAY + LEG. HOLIDAY OT",
            "EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY OT","EX. NDOT","EX. SUNDAY NDOT",
            "EX. SPECIAL HOL. NDOT","EX. SPECIAL HOL. + SUNDAY NDOT","EX. LEG. HOLIDAY NDOT",
            "EX. LEG. HOLIDAY + SUNDAY NDOT","EX. LEG. HOLIDAY + LEG. HOLIDAY NDOT",
            "EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY NDOT"," "
        ]

        all_dates = pd.date_range(start_date, end_date)
        day_numbers = [d.strftime("%d") for d in all_dates]
        weekday_names = [d.strftime("%a") for d in all_dates]

        second_header = ["ID", "NAME", "Type"] + day_numbers + [
            "Indicate as Notes/Comments the Date", "HRS", "HRS"
        ]
        adjustments_idx = second_header.index("Indicate as Notes/Comments the Date")  # find the "ADJUSTMENTS" column # the adjustment column is not yet created just find the

        # ===== Step 4: Build data rows from dtr_report =====
        rows = []
        for emp_id, emp_name in df[["unique_id", "employee_name"]].drop_duplicates().values:
            emp_data = df[df["unique_id"] == emp_id]
            for rtype in row_types:
                row = [emp_id, emp_name, rtype]
                if rtype.lower() == "adjustment":
                    """
                    first locate the adjustment column and the row of ""
                    then insert the hours dont for loop just insert if there is already a value just add it to the current value
                    after that insert the comments same as last time if there is already a comment just add using a comma 
                    then continue is that so hard
                    """
                    # get all adjustment entries for this employee
                    adjustment_entries = emp_data[emp_data["type"].str.lower() == "adjustment"]

                    # total hours (0 if empty)
                    total_adjustment = adjustment_entries["hours"].sum()

                    # insert hours into the ADJUSTMENTS column (add if already has value)
                    if row[adjustments_idx] in ("", None):
                        row[adjustments_idx] = total_adjustment
                    else:
                        row[adjustments_idx] += total_adjustment

                    # prepare comment string
                    comments = adjustment_entries.apply(
                        lambda r: f"{r['record_date'].strftime('%Y-%m-%d') if hasattr(r['record_date'], 'strftime') else r['record_date']}: {r['hours']}",
                        axis=1
                    ).tolist()
                    comment_text = ", ".join(comments)

                    # attach comment to Excel cell (assuming 'cell' is already the correct ws.cell)
                    if comment_text:
                        if cell.comment:
                            cell.comment.text += f", {comment_text}"
                        else:
                            cell.comment = Comment(comment_text, "")

                    continue  # skip the daily hours loop
                   
                for day in all_dates:
                    day_str = day.strftime("%Y-%m-%d")
                    match = emp_data[(emp_data["record_date"] == day_str) & (emp_data["type"] == rtype)]
                    hours_val = match["hours"].sum() if not match.empty else 0
                    # leave cell blank if 0
                    row.append(hours_val if hours_val != 0 else "")
                
                row += ["", "", ""]
                rows.append(row)

        df_data = pd.DataFrame(rows, columns=second_header)

        # ==== step
        # check if there is any adjustments 


    
        # Step 4.5: Compute total and sprout formulas
        total_idx = second_header.index("HRS")     # last HRS in second_header is TOTAL
        sprout_idx = second_header.index("HRS", total_idx + 1)  # next HRS is Sprout
        for i, row in enumerate(df_data.itertuples(index=False), start=4):  # Excel starts data at row 7 (adjust if needed)
            row_type = row[2]  # assuming: unique_id, employee_name, rtype, ...
            # total_col = df_data.columns.get_loc("TOTAL")
            # sprout_col = df_data.columns.get_loc("Sprout")

            # Example: range for daily hours columns
            first_day_col = 'D'  # if your days start at column D (adjust as needed)
            last_day_col = chr(ord(first_day_col) + len(all_dates) - 1)
            if (i - 4 + 1) % 33 == 0:
                continue  # skip yellow total rows
            if row_type == "Hours Worked":
                # Total and Sprout columns as integer sums
                #total_formula  = f"=SUM({first_day_col}{i}:{last_day_col}{i})"
                total_formula = f"=SUM({first_day_col}{i}:{last_day_col}{i})"
                sprout_formula = f"=SUM({first_day_col}{i}:{last_day_col}{i})"
            else:
                # Convert sum to hh:mm format for other types
                #total_formula  = f'=TEXT(SUM({first_day_col}{i}:{last_day_col}{i})/24, "[hh]:mm")'
                total_formula = f"=SUM({first_day_col}{i}:{last_day_col}{i})"
                sprout_formula = f'=TEXT(SUM({first_day_col}{i}:{last_day_col}{i})/24, "[hh]:mm")'
            
            # Insert formula directly into df_data at the correct column positions
            df_data.iat[i - 4, total_idx]  = total_formula
            df_data.iat[i - 4, sprout_idx] = sprout_formula


       
        # ===== Step 5: Write data to Excel =====
        os.makedirs(os.path.dirname(output_file_path) or ".", exist_ok=True)
        with pd.ExcelWriter(output_file_path, engine="openpyxl", mode="w") as writer:
            df_data.to_excel(writer, sheet_name="Manual Report", index=False, header=False, startrow=3)

        wb = load_workbook(output_file_path)
        ws = wb["Manual Report"]
        ncols = len(second_header)
        # Replace your current 32-row-sum block with this
        rows_to_sum = 32
        start_row = 4
        last_row = ws.max_row
        yellow = PatternFill(start_color="FFFF00", end_color="FFFF00", fill_type="solid")

        logging.info(f"Start 32-row sum: start_row={start_row}, last_row={last_row}")

        rows_to_sum = 32
        start_row = 4
        yellow = PatternFill(start_color="FFFF00", end_color="FFFF00", fill_type="solid")

        row = start_row
        while True:
            # stop if Column A is empty
            if ws.cell(row, 1).value in (None, ""):
                break

            end_row = row + rows_to_sum - 1
            if ws.cell(end_row, 1).value in (None, ""):
                # adjust end_row if fewer than rows_to_sum remaining
                end_row = row
                while ws.cell(end_row, 1).value not in (None, ""):
                    end_row += 1
                end_row -= 1

            sum_row = end_row + 1
            ws.cell(sum_row, 21).value = f"=SUM(U{row}:U{end_row})"
            ws.cell(sum_row, 21).fill = yellow

            # next block starts **after sum_row**
            row = sum_row + 1

        # check_cell = ws["W36"]
        # print("Debug check:", check_cell.value)

        # ===== Step 6: Create headers =====
        # Row1 top header
        for c in range(1, ncols + 1):
            ws.cell(row=1, column=c).value = ""
        ws.cell(row=1, column=ncols-2).value = "ADJUSTMENTS"
        ws.cell(row=1, column=ncols-1).value = "TOTAL"
        ws.cell(row=1, column=ncols).value     = "Sprout"

        # Row2 column titles
        for idx, val in enumerate(second_header, start=1):
            ws.cell(row=2, column=idx).value = val

        # Row3 weekday names
        for c in range(1, 4):
            ws.cell(row=3, column=c).value = ""
        for i, wd in enumerate(weekday_names, start=4):
            ws.cell(row=3, column=i).value = wd

        # ===== Step 7: Header styling =====
        header_font = Font(name="Arial", size=8, color="FFFFFF", bold=True)
        header_fill = PatternFill("solid", fgColor="002060")
        center_align = Alignment(horizontal="center", vertical="center", wrap_text=True)

        for r in (1, 2, 3):
            for c in range(1, ncols + 1):
                cell = ws.cell(row=r, column=c)
                if not cell.value:
                    cell.value = ""
                cell.font = header_font
                cell.fill = header_fill
                cell.alignment = center_align

        ws.row_dimensions[1].height = 12.75
        ws.row_dimensions[2].height = 64.5
        ws.row_dimensions[3].height = 12.75
        ws.column_dimensions["A"].width = 19.71
        ws.column_dimensions["B"].width = 40.43
        ws.column_dimensions["C"].width = 41.29
        ws.column_dimensions["S"].width = 22.71
        ws.freeze_panes = ws["A4"]

        # ===== Step 8: Conditional formatting by Type =====
        group1 = {
            "Hours Worked","SUNDAY Reg 8 hrs","SPECIAL HOL. + SUNDAY Reg 8 hrs",
            "LEG. HOLIDAY + SUNDAY Reg 8 hrs","LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY Reg 8 hrs",
            "SUNDAY ND Reg 8 hrs","SPECIAL HOL. + SUNDAY ND Reg 8 hrs",
            "LEG. HOLIDAY + SUNDAY ND Reg 8 hrs","LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY ND Reg 8 hrs"
        }
        gold_fill = PatternFill("solid", fgColor="FFF2CC")
        red_font = Font(name="Arial", size=8, color="FF0000")
        normal_font = Font(name="Arial", size=8, color="000000")
        blue_fill = PatternFill("solid", fgColor="AEC6CF")

        blue_group = {
            "OT (Ordinary day)","EX SUNDAY OT","EX SPECIAL HOL. OT","EX SPECIAL HOL. + SUNDAY OT",
            "EX LEG. HOLIDAY OT","EX. LEG HOLIDAY + SUNDAY OT","EX. LEG. HOLIDAY + LEG. HOLIDAY OT",
            "EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY OT","EX. NDOT","EX. SUNDAY NDOT",
            "EX. SPECIAL HOL. NDOT","EX. SPECIAL HOL. + SUNDAY NDOT","EX. LEG. HOLIDAY NDOT",
            "EX. LEG. HOLIDAY + SUNDAY NDOT","EX. LEG. HOLIDAY + LEG. HOLIDAY NDOT",
            "EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY NDOT"
        }
        red_only = {
            "EX SUNDAY OT","EX SPECIAL HOL. + SUNDAY OT","EX. LEG HOLIDAY + SUNDAY OT",
            "EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY OT","EX. SUNDAY NDOT","EX. SPECIAL HOL. + SUNDAY NDOT",
            "EX. LEG. HOLIDAY + SUNDAY NDOT","EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY NDOT"
        }

        start_data_row = 4
        for r in range(start_data_row, ws.max_row + 1):
            type_cell = ws.cell(row=r, column=3)
            val = str(type_cell.value).strip() if type_cell.value else ""
            if val in group1:
                type_cell.fill = gold_fill
                type_cell.font = red_font
            elif val in blue_group:
                type_cell.fill = blue_fill
                type_cell.font = red_font if val in red_only else normal_font
            else:
                type_cell.fill = PatternFill(fill_type=None)
                type_cell.font = normal_font

        # ===== Step 9: Borders =====
        thin = Side(border_style="thin", color="000000")
        border = Border(top=thin, left=thin, right=thin, bottom=thin)
        for row in ws.iter_rows(min_row=1, max_row=ws.max_row, min_col=1, max_col=ncols):
            for cell in row:
                cell.border = border
                if cell.row <= 3:
                    cell.alignment = center_align


        
       


        wb.save(output_file_path)
        print(f"Manual report written to: {output_file_path}")

    except Exception as ex:
        print(f"Error report manual: {ex}")


def clear_dtr():
    """
    Delete all records from the dtr_report table using DELETE.
    Uses a transaction to ensure atomicity.
    """
    try:
        with engine.begin() as conn:  # begin transaction
            conn.execute(text("DELETE FROM dtr_report"))
        logging.info("dtr_report has been cleared successfully using DELETE.")
    except Exception as e:
        logging.error(f"Failed to clear dtr_report: {e}")

def generate_security_report_if_data(output_path, logo_path, engine, biometric_imports_id):
    """
    Check if there is any data in security_attendance table for a specific biometric_imports_id.
    If yes, generate the security report. Otherwise, skip.
    """
    try:
        query = text(
            "SELECT 1 FROM security_attendance WHERE biometric_imports_id = :biometric_id LIMIT 1"
        )
        with engine.connect() as conn:
            result = conn.execute(query, {"biometric_id": biometric_imports_id}).fetchone()

        if result:
            # At least one record exists, generate report
            security_report_generate(output_path, logo_path, engine)
        else:
            logging.info(f"No data in security_attendance for biometric_imports_id={biometric_imports_id} — skipping security report.")
    except Exception as e:
        logging.error(f"Failed to check security_attendance table: {e}")

def main(
    input_csv_file,
    output_directory,
    image_pathway,
    biometric_imports_id,
):
    """Main function to orchestrate the employee data processing."""
    try:
       
   
        # Create output directory if it doesn't exist
        os.makedirs(output_directory, exist_ok=True)

        # Hardcoded output filenames
        output_excel_file = "payroll file.xlsx"
        output_csv_file = "payroll file.csv"
        output_report_file = "reportdtr.xlsx"
        output_security_file = "security.xlsx"

        # Full paths for output files
        output_excel_path = os.path.join(output_directory, output_excel_file)
        output_csv_path = os.path.join(output_directory, output_csv_file)
        output_report_file = os.path.join(output_directory, output_report_file)
        output_security_path = os.path.join(output_directory, output_security_file)

        
        
        # update attendance records to leaves if match
        update_leaves_attendance_record(biometric_imports_id)

        df, data = load_data_from_db(biometric_imports_id=biometric_imports_id)

        if df is None or data is None:
            # print("Failed to read CSV files.")
            return

        # # Preprocessing names, merging data, calculating hours, etc.
        df = calculate_hours_worked(df,data, biometric_imports_id)
        df_grouped = group_employee_data(df)


        # # Preparing the output Excel and CSV files
        prepare_excel(df_grouped, output_excel_path)
        excel_to_csv(output_excel_path, output_csv_path)
        # Pass the grouped data and path to your report function
        report_manual(conn, output_report_file, biometric_imports_id)
        logo_path = image_pathway
        clear_dtr()
        # Generate security report if there is data
        generate_security_report_if_data(output_security_path, logo_path, engine, biometric_imports_id=biometric_imports_id)
        
        
        print("Successful")

    except Exception as ex:
        logging.info(f"Error in main: {ex}")


# Argument parser setup
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
# parser.add_argument(
#     "user_id", type=str, help="The user_id"
# )

args = parser.parse_args()

# Call the main function with the provided arguments
main(
    args.input_csv_file,
    args.output_directory,
    args.image_pathway,
    args.biometric_imports_id,

)


