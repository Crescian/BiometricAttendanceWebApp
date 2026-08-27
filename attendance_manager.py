import argparse
import pandas as pd
import os
import json
import math
import threading
import tempfile
import csv
import re
from datetime import date, timedelta, datetime
import holidays
import psycopg2
import psycopg2
from sqlalchemy import create_engine
from sqlalchemy import text
from dotenv import load_dotenv
from urllib.parse import quote_plus
import logging
from autocompute_attendance import conn, engine, log_overtime_to_db, merge_all_rd_entries
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)
# Configure logging
logging.basicConfig(
    filename='app.log',       # Log file name
    filemode='w',             # 'a' to append, 'w' to overwrite
    format='%(asctime)s - %(levelname)s - %(message)s',  # Log format
    level=logging.DEBUG        # Minimum level of messages to log
)


# Shared variables
conversion_result = None
rd_ot_variable = 0

def log_security_db(conn, row, type, hours, biometrics_id):
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
                LIMIT 1;
            """, (employee_id, record_date, earliest_time, latest_time))
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
                        (employee_management_id, record_date, weekday, earliest_time, latest_time, hours_worked, biometrics_id)
                        VALUES (%s, %s, %s, %s, %s, %s);
                    """
                    values = (employee_id, record_date, weekday, earliest_time, latest_time, hours, biometrics_id)

                elif type == "OT":
                    query = """
                        INSERT INTO security_attendance
                        (employee_management_id, record_date, weekday, earliest_time, latest_time, ot, biometrics_id)
                        VALUES (%s, %s, %s, %s, %s, %s);
                    """
                    values = (employee_id, record_date, weekday, earliest_time, latest_time, hours, biometrics_id)

                elif type == "ND":
                    query = """
                        INSERT INTO security_attendance
                        (employee_management_id, record_date, weekday, earliest_time, latest_time, nd, biometrics_id)
                        VALUES (%s, %s, %s, %s, %s, %s);
                    """
                    values = (employee_id, record_date, weekday, earliest_time, latest_time, hours, biometrics_id)

                else:
                    logging.info(f"Unknown type: {type}. No insert performed.")
                    return

                cur.execute(query, values)
                conn.commit()
                logging.info(f"Inserted {type} record for {employee_name} ({weekday}, {record_date}).")

    except Exception as ex:
        logging.info(f"Error logging security DB for {row.get('employee_name', 'Unknown')}: {ex}")
        conn.rollback()

# def log_overtime_to_db(conn, row,
#     ord_ot, rd_ot,
#     ord_nd, ord_nd_ot,
#     rd_nd, rd_nd_ot,
#     rd, total_non_working_days_present,
#     late, late_hours, late_minutes,
#     out_time_required,
#     type, schedule, status, biometric_imports_id, attendance_records_id):

    

#     # get the record_date for attendance_record table using the attendance_record_id if there is no record 

#     def trim_days(ts):
#         s = str(ts or "").strip()
#         return re.sub(r"^\d+\s+days?\s+", "", s)

#     last = row["employee_name"].split(",")[0].strip()
#     first = row["employee_name"].split(",")[1].strip()
#     record_date = row.get("record_date")
#     if not record_date:
#         with conn.cursor() as cur:
#             cur.execute("""
#                 SELECT record_date
#                 FROM attendance_record
#                 WHERE id = %s
#             """, (attendance_records_id,))
#             result = cur.fetchone()
#             if result:
#                 record_date = result[0]
#     earliest    = trim_days(row.get("earliest_time"))
#     latest      = trim_days(row.get("latest_time"))
#     latest_time = row.get("latest_time")
#     if latest_time is None or latest_time == pd.Timedelta(0):
#         latest_time_db = "00:00:00"
#     elif isinstance(latest_time, pd.Timedelta):
#         total_seconds = int(latest_time.total_seconds())
#         hours = total_seconds // 3600
#         minutes = (total_seconds % 3600) // 60
#         seconds = total_seconds % 60
#         latest_time = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
#     else:
#         latest_time = str(latest_time)

#      # Fetch unique_id from employee_management using employee_name
#     with conn.cursor() as cur:
#         cur.execute("""
#             SELECT unique_id, department, serial_number
#             FROM employee_management
#             WHERE employee_name = %s
#         """, (row["employee_name"],))
#         result = cur.fetchone()

#     id_str = result[0] if result else "TMNG-000000-000"
#     department = result[1] if result else None
#     serial_number = result[2] if result else None

#     # id_val = row.get("unique_id")
#     # id_str = str(id_val).strip() if pd.notna(id_val) else ""
#     # department = row.get("Department Name")
#     # serial_number = row.get("Serial Number")
#     attendance_area = row.get("Attendance Area")
    

#     new_entry = {
#         "id": id_str or "TMNG-000000-000",
#         "first_name": first,
#         "last_name":  last,
#         "employee_name": f"{last}, {first}",
#         "record_date": record_date,
#         "earliest_time": earliest,
#         "latest_time":   latest_time,
#         "type": type,
#         "department": department,
#         "attendance_area": "COA",
#         "serial_number": serial_number,
#         "schedule": schedule,
#         "ord_ot": f"{int(ord_ot):02d}:{int(round((ord_ot - int(ord_ot)) * 60)):02d}" if ord_ot is not None else "00:00",
#         "rd_ot": f"{int(rd_ot):02d}:{int(round((rd_ot - int(rd_ot)) * 60)):02d}" if rd_ot is not None else "00:00",
#         "ord_nd": f"{int(ord_nd):02d}:{int(round((ord_nd - int(ord_nd)) * 60)):02d}" if ord_nd is not None else "00:00",
#         "ord_nd_ot": f"{int(ord_nd_ot):02d}:{int(round((ord_nd_ot - int(ord_nd_ot)) * 60)):02d}" if ord_nd_ot is not None else "00:00",
#         "rd_nd": f"{int(rd_nd):02d}:{int(round((rd_nd - int(rd_nd)) * 60)):02d}" if rd_nd is not None else "00:00",
#         "rd_nd_ot": f"{int(rd_nd_ot):02d}:{int(round((rd_nd_ot - int(rd_nd_ot)) * 60)):02d}" if rd_nd_ot is not None else "00:00",
#         "rd": f"{int(rd):02d}:{int(round((rd - int(rd)) * 60)):02d}" if rd is not None else "00:00",
#         "total_non_working_days_present": total_non_working_days_present,
#         "late": late,
#         "late_hours": late_hours,
#         "late_minutes": late_minutes,
#         "out_time_required": out_time_required,
#         'status': status,
#         "biometric_imports_id":biometric_imports_id,
#         "attendance_records_id":attendance_records_id
#     }

#     try:
#         with conn.cursor() as cur:
#             # ✅ Duplicate check before insert
#             cur.execute("""
#                 SELECT id, rd, rd_ot, rd_nd, rd_nd_ot
#                 FROM overtimes
#                 WHERE employee_name = %s
#                 AND record_date = %s
#                 AND type = %s
#                 AND biometric_imports_id = %s
#             """, (new_entry["employee_name"], new_entry["record_date"], new_entry["type"], new_entry["biometric_imports_id"]))
            
#             existing = cur.fetchone()
            
#             if existing:
#                 existing_id, existing_rd, existing_rd_ot, existing_rd_nd, existing_rd_nd_ot = existing
                
#                 if new_entry["type"] == "ord":
#                     logging.info(f"Duplicate entry skipped for {new_entry['employee_name']} on {new_entry['record_date']} ({new_entry['type']})")
#                     return existing_id
                
#                 elif new_entry["type"].lower() == "rd":
#                     # Only update RD if changed
#                     if new_entry["rd"] != existing_rd:
#                         cur.execute("""
#                             UPDATE overtimes
#                             SET rd = %s
#                             WHERE id = %s
#                         """, (new_entry["rd"], existing_id))
#                         conn.commit()
#                         logging.info(f"Updated RD field for {new_entry['employee_name']} on {new_entry['record_date']}")
                    
#                     # Only update RD OT/ND if any of the values changed
#                     if (new_entry["rd_ot"] != existing_rd_ot or
#                         new_entry["rd_nd"] != existing_rd_nd or
#                         new_entry["rd_nd_ot"] != existing_rd_nd_ot):
                        
#                         cur.execute("""
#                             UPDATE overtimes
#                             SET rd_ot = %s,
#                                 rd_nd = %s,
#                                 rd_nd_ot = %s
#                             WHERE id = %s
#                         """, (
#                             new_entry["rd_ot"],  
#                             new_entry["rd_nd"], 
#                             new_entry["rd_nd_ot"],
#                             existing_id
#                         ))
#                         conn.commit()
#                         logging.info(f"Updated RD OT/ND fields for {new_entry['employee_name']} on {new_entry['record_date']}")
                
#                 # Return the database ID regardless
#                 return existing_id
#             # ✅ Proceed to insert only if no duplicate
#             cur.execute("""
#                 INSERT INTO overtimes (
#                     unique_id, first_name, last_name, employee_name,
#                     earliest_time, latest_time, type, department, attendance_area,
#                     serial_number, schedule, ord_ot, rd_ot, ord_nd, ord_nd_ot,
#                     rd, rd_nd, rd_nd_ot, total_non_working_days_present, late,
#                     late_hours, late_minutes, out_time_required, record_date, status, biometric_imports_id, attendance_records_id
#                 )
#                 VALUES (
#                     %(id)s, %(first_name)s, %(last_name)s, %(employee_name)s,
#                     %(earliest_time)s, %(latest_time)s, %(type)s,
#                     %(department)s, %(attendance_area)s, %(serial_number)s, %(schedule)s,
#                     %(ord_ot)s, %(rd_ot)s, %(ord_nd)s, %(ord_nd_ot)s, %(rd)s, %(rd_nd)s, %(rd_nd_ot)s,
#                     %(total_non_working_days_present)s, %(late)s, %(late_hours)s, %(late_minutes)s,
#                     %(out_time_required)s, %(record_date)s, %(status)s,%(biometric_imports_id)s,%(attendance_records_id)s
#                 )
#                 RETURNING id
#             """, new_entry)
#             new_id = cur.fetchone()[0]

#         conn.commit()
#         return new_id

#     except Exception as e:
#         conn.rollback()
#         logging.info("Insert failed:", e)
#         raise


def autocalculate_ord(row, non_working_days,data,biometric_imports_id, attendance_records_id, certificate_attendance_id):
    try:
        
        # 1) Identify date & skip non‐working days
        record_date = str(row["date"]).split(" ")[0]
        #logging.info(f"record date ord {type(record_date)}")

        cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
        # convert MM/DD/YYYY string to YYYY-MM-DD on the fly
        
        #logging.info(f"rocessing record_date: {record_date}")  #  logging.info each record_date
        if record_date in cleaned_non_working_days:
            
            logging.info(f"skip record_date: {record_date}")
            return [0, 0, 0]
        
        # earliest_time = row["earliest_time"]  # Timedelta since midnight
        # latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
        earliest_time = pd.to_timedelta(row["earliest_time"])
        latest_time = pd.to_timedelta(row.get("latest_time", "00:00:00"))
        
        # Force latest_time to Timedelta (with fallback)
        
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
        
        #employee_name = str(row["employee_name"])
        certificate_pd = pd.read_sql(
                f"""
                SELECT 
                    certificate_attendance.*,
                    employee_management.employee_name,
                    employee_management.department,
                    employee_management.schedule
                FROM certificate_attendance
                INNER JOIN employee_management
                    ON employee_management.id = certificate_attendance.employee_management_id
                WHERE certificate_attendance.id = {certificate_attendance_id}
                """,
                engine
            )
        # Extract employee_name properly - handle case where it might be a Series
        if certificate_pd.empty:
            logging.error(f"No data found for certificate_attendance_id: {certificate_attendance_id}")
            return [0, 0, 0]
        
        # Log available columns for debugging
        logging.info(f"certificate_pd columns: {list(certificate_pd.columns)}")
        
        # Use alias to avoid conflicts - use .get() to safely access columns
        row_dict = certificate_pd.iloc[0].to_dict()
        employee_name = str(certificate_pd.iloc[0]["employee_name"]).strip()
        row["employee_name"] = employee_name
        
        
        

        department = str(certificate_pd.iloc[0]["department"]).strip()
        row["department"] = department
        print(f"department {department}")
        print(f"employee name {employee_name}")
        schedule = str(certificate_pd.iloc[0]["schedule"]).strip()
        print(schedule)


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
            match = data[data["employee_name"].astype(str).str.strip().str.upper() == employee_name.strip().upper()]
            if match.empty:
                print(f"No match found for employee: '{employee_name}'")
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
        if schedule in ("15-23","23-7","9-15"):
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
            # logging.info(f"nTotal OT accumulated: {ot_total}")

            if ot_total >= pd.Timedelta(hours=1):
                remaining_first_hour = pd.Timedelta(hours=1)

                for block, is_nd in ot_blocks:
                    # logging.info(f"rocessing OT block: {block}, ND={is_nd}")

                    # take from first OT hour
                    if remaining_first_hour > pd.Timedelta(0):
                        take = min(block, remaining_first_hour)
                        if is_nd:
                            ord_nd_ot += take
                            # logging.info(f"  Counted ND OT (first hour): {take}")
                            # logging.info(f"  Total ND OT so far: {ord_nd_ot}")
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
                            # logging.info(f"  Counted ND OT chunks: {take}")
                            # logging.info(f"  Total ND OT so far: {ord_nd_ot}")
                        else:
                            ord_ot += take
                            #logging.info(f"  Counted OT chunks: {take}")
                    else:
                        if block > pd.Timedelta(0):
                            pass
                            #logging.info(f"  Ignored leftover OT under 30m: {block}")
            else:
                pass
                #logging.info("otal OT less than 1h → ignored")

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
                                min(latest_time, pd.to_timedelta("24:00:00")) - max(earliest_time, nd_start))
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
                        # leftover <30 min ignored

                # --- Add non-ND time to ORD OT if total > 8 hrs ---
                if total_worked > pd.Timedelta(hours=8):
                    # Non-ND = total - ND parts
                    non_nd_time = total_worked - (ord_nd + ord_nd_ot)
                    if non_nd_time > pd.Timedelta(0):
                        ord_ot += non_nd_time

                logging.info(f"ord_nd={ord_nd}, ord_nd_ot={ord_nd_ot}, ord_ot={ord_ot}")
        
            if day_shift:
                print(11)
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


            logging.info(
                f"ord_ot={ord_ot.total_seconds()}, "
                f"ord_nd={ord_nd.total_seconds()}, "
                f"ord_nd_ot={ord_nd_ot.total_seconds()}, "
                f"condition={(ord_ot.total_seconds() <= 0 and ord_nd.total_seconds() <= 0 and ord_nd_ot.total_seconds() <= 0)}"
            )
            if not (ord_ot.total_seconds() <= 0 and ord_nd.total_seconds() <= 0 and ord_nd_ot.total_seconds() <= 0):
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

                    # --- Log to both DBs ---
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
                        status="Pending", biometric_imports_id=biometric_imports_id, attendance_records_id=attendance_records_id, schedule_shift=schedule_shift,update_target="ord"
                    )

                    # # ✅ Do NOT return any values for security
                    # return

                else:
                    # Non-security employees
                    # print("zxcxzc")
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
                            status="Pending",  biometric_imports_id=biometric_imports_id, attendance_records_id=attendance_records_id, schedule_shift=schedule_shift,update_target="ord"
                        )

                # ✅ Only return values for non-security
               
                return [
                    round(ord_ot.total_seconds() / 3600, 2),
                    round(ord_nd.total_seconds() / 3600, 2),
                    round(ord_nd_ot.total_seconds() / 3600, 2),
                ]

                
    except Exception as ex:
        logging.info(f"Error auto-calculating ORD: {ex}")
        return [0, 0, 0]

def autocalculate_rd_overtime(row, non_working_days,data,biometric_imports_id, attendance_records_id, certificate_attendance_id):
    try:
        
        logging.info("asd")
        # ✅ Pull temp_sched table directly from PostgreSQL
        #temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments", engine)
        temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)

        #temp_sched_pd["employee_name"] = temp_sched_pd["last_name"].str.strip() + ", " + temp_sched_pd["first_name"].str.strip()
        #temp_sched_pd["record_date"] = temp_sched_pd["record_date"]  # normalise the column name
        record_date = str(row["date"]).split(" ")[0]
        print(record_date)

        logging.info("8232")
        cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
        if record_date not in cleaned_non_working_days:
            return [0, 0, 0]
        # earliest_time = row["earliest_time"]  # Timedelta since midnight
        # latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
        earliest_time = pd.to_timedelta(row["earliest_time"])
        latest_time = pd.to_timedelta(row.get("latest_time", "00:00:00"))
        if earliest_time == latest_time:
            return [0, 0, 0]
        
        logging.info("nasdsa")
        #logging.info(33)
        # 2) Build actual in/out datetimes from the row’s punches
        # in_td   = row["earliest_time"]
        in_td = row.get("earliest_time", pd.to_timedelta("00:00:00"))
        out_td  = row.get("latest_time", pd.to_timedelta("00:00:00"))
        date_base = pd.to_datetime(record_date,errors="coerce")
        # in_time   = date_base + in_td
        # out_time  = date_base + out_td
        logging.info("8asd")
        
        # 3) Validate & handle cross‐midnight
        if earliest_time == latest_time:
            return [0, 0, 0]
        if latest_time <= earliest_time:
            out_time += pd.Timedelta(days=1)
        out_time = date_base + latest_time
        # Build the combined name
        #employee_name = f"{last_name}, {first_name}"
        # employee_name = str(row["employee_name"])
        certificate_pd = pd.read_sql(
                f"""
                SELECT 
                    certificate_attendance.*,
                    employee_management.employee_name AS emp_name,
                    employee_management.department
                FROM certificate_attendance
                INNER JOIN employee_management
                    ON employee_management.id = certificate_attendance.employee_management_id
                WHERE certificate_attendance.id = {certificate_attendance_id}
                """,
                engine
            )
        # Extract employee_name properly - handle case where it might be a Series
        if certificate_pd.empty:
            logging.error(f"No data found for certificate_attendance_id: {certificate_attendance_id}")
            return [0, 0, 0]
        
        # Use alias to avoid conflicts - use .get() to safely access columns
        row_dict = certificate_pd.iloc[0].to_dict()
        employee_name_raw = row_dict.get("emp_name") or row_dict.get("employee_name")
        
        if employee_name_raw is None:
            logging.error(f"employee_name column not found. Available columns: {list(certificate_pd.columns)}")
            return [0, 0, 0]
        
        if isinstance(employee_name_raw, pd.Series):
            employee_name = str(employee_name_raw.iloc[0]).strip()
        else:
            employee_name = str(employee_name_raw).strip()
        department = str(certificate_pd.iloc[0]["department"])
        row["employee_name"] = employee_name
        row["department"] = department


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
            logging.info("99999999")

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
        logging.info("2323")
        
        
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
        # Assume: schedule already determined
        logging.info("SSSA")
        day_shift = schedule in ("7-16", "8-17", "7-19","6-15","9-15","10-18","10-16")
        night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")
        schedule_shift = "dayshift"
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
        if schedule in ("15-23","23-7","9-15"):
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

        logging.info("2323")
        
        # if 23-8 minus 1 hr for lunch in rd_nd
        if schedule.strip() in ["23-8"]:
            rd_nd = rd_nd - pd.Timedelta(hours=1)
            #logging.info("fter",rd_nd)
            


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
        
        
        elif day_shift:
            print(11)
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

        logging.info(f"rd_nd={rd_nd}, rd_nd_ot={rd_nd_ot}, ord_ot={rd_ot}")
        logging.info(f"RD OT DEBUG] {employee_name} | IN: {in_time} | OUT: {out_time} | RD ND {rd_nd} RD OT {rd_ot} RD ND OT {rd_nd_ot}")
        
        if not (rd_ot.total_seconds() <= 0 and rd_nd.total_seconds() <= 0 and rd_nd_ot.total_seconds() <= 0):

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
                    late=late,
                    late_hours=late_hours,
                    late_minutes=late_minutes,
                    out_time_required=out_time_required,
                    type="RD",
                    schedule=schedule,
                    status="Pending", biometric_imports_id=biometric_imports_id, schedule_shift=schedule_shift,update_target="rd_ot"
                )

                # # ✅ Do NOT return any values for security
                # return

            else:
                # Non-security employees
                rd_ot_val = round(rd_ot.total_seconds() / 3600, 2)
                rd_nd_val = round(rd_nd.total_seconds() / 3600, 2)
                rd_nd_ot_val = round(rd_nd_ot.total_seconds() / 3600, 2)

                if rd_ot.total_seconds() != 0 or rd_nd.total_seconds() != 0 or rd_nd_ot.total_seconds() != 0:

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
                        status="Pending",  biometric_imports_id=biometric_imports_id, attendance_records_id=attendance_records_id,schedule_shift=schedule_shift,update_target="rd_ot"
                    )

            # ✅ Only return values for non-security
            return [
                rd_ot_val,
                rd_nd_val,
                rd_nd_ot_val,
            ]

    except Exception as ex:
        logging.info(f"Error auto‐calculating RD overtime: {ex}")
        return [0, 0, 0]


def autocompute_rd(row, non_working_days,data,biometric_imports_id, attendance_records_id, certificate_attendance_id):
    try:
        #logging.info(1100)
        # 🔹 Recreate employee match here
        # last_name     = row["last_name"].strip()
        # first_name    = row["first_name"].strip()
        # 1) Pull & clean the record_date
        logging.info("555")
        record_date = str(row["date"]).split(" ")[0]

        cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
        
        # ✅ Pull temp_sched table directly from PostgreSQL
        #temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments", engine)
        temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)


        #temp_sched_pd["employee_ name"] = temp_sched_pd["last_name"].str.strip() + ", " + temp_sched_pd["first_name"].str.strip()
        #temp_sched_pd["record_date"] = temp_sched_pd["record_date"]  # normalise the column name
        #employee_name = f"{last_name}, {first_name}"
        #employee_name = str(row["employee_name"])
        certificate_pd = pd.read_sql(
                f"""
                SELECT 
                    certificate_attendance.*,
                    employee_management.employee_name AS emp_name,
                    employee_management.department
                FROM certificate_attendance
                INNER JOIN employee_management
                    ON employee_management.id = certificate_attendance.employee_management_id
                WHERE certificate_attendance.id = {certificate_attendance_id}
                """,
                engine
            )
        # Extract employee_name properly - handle case where it might be a Series
        if certificate_pd.empty:
            logging.error(f"No data found for certificate_attendance_id: {certificate_attendance_id}")
            return 0.0
        
        # Use alias to avoid conflicts - check available columns first
        if "emp_name" in certificate_pd.columns:
            employee_name_raw = certificate_pd.iloc[0]["emp_name"]
        elif "employee_name" in certificate_pd.columns:
            employee_name_raw = certificate_pd.iloc[0]["employee_name"]
        else:
            logging.error(f"employee_name column not found. Available columns: {list(certificate_pd.columns)}")
            return 0.0
        
        if isinstance(employee_name_raw, pd.Series):
            employee_name = str(employee_name_raw.iloc[0]).strip()
        else:
            employee_name = str(employee_name_raw).strip()
        department = str(certificate_pd.iloc[0]["department"])
        row["employee_name"] = employee_name
        row["department"] = department


        logging.info("888")
        

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
                return [0, 0, 0]
            schedule = match.iloc[0]["schedule"]
            if isinstance(schedule, pd.Series):
                schedule = schedule.iloc[0]
        # earliest_time = row["earliest_time"]  # Timedelta since midnight
        # latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
        earliest_time = pd.to_timedelta(row["earliest_time"])
        latest_time = pd.to_timedelta(row.get("latest_time", "00:00:00"))
        #logging.info(1300)
        # 4) Determine late‐cutoff (for morning rounding)
        # late_cutoff = pd.to_timedelta("07:15:00") if schedule == "7-16" else pd.to_timedelta("08:15:00")
        if schedule:
            logging.info(f"schedule: {schedule}")
            logging.info("99")
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

                logging.info("999")

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
        if day_shift:
            schedule_shift = "day shift"
        elif night_shift:
            schedule_shift = "night shift"
        else:
            schedule_shift = None

        # 3) Parse raw punches into timestamps
        in_td  = pd.to_timedelta(row["earliest_time"], errors="coerce")
        out_td = pd.to_timedelta(row.get("latest_time", "00:00:00"), errors="coerce")
        if pd.isna(in_td) or pd.isna(out_td):
            return 0.0

        date_base = pd.to_datetime(record_date, format="%Y-%m-%d", errors="coerce")
        in_time   = date_base + earliest_time   # ← use overridden earliest_time
        out_time  = date_base + latest_time     # ← use overridden latest_time
        
       
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
        if schedule.strip() not in ["15-23", "23-7","9-15"]:
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
                all_rd = rd_ot_variable + rd_val
                log_security_db(conn, row, "OT", all_rd, biometric_imports_id)
                

                log_overtime_to_db(
                    conn,
                    row,
                    ord_ot=0,
                    rd_ot=0,
                    ord_nd=0,
                    ord_nd_ot=0,
                    rd_nd=rd_nd_val,
                    rd_nd_ot=rd_nd_ot_val,
                    rd=rd_val,
                    total_non_working_days_present=0,
                    late=late,
                    late_hours=late_hours,
                    late_minutes=late_minutes,
                    out_time_required=out_time_required,
                    type="RD",
                    schedule=schedule,
                    status="Pending", biometric_imports_id=biometric_imports_id,attendance_records_id=attendance_records_id, schedule_shift=schedule_shift,update_target="rd"
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
                    status="Pending", biometric_imports_id=biometric_imports_id,attendance_records_id=attendance_records_id, schedule_shift=schedule_shift,update_target="rd"
                )

            # ✅ Only return hours for non-security
            return hours

    except Exception as e:
        logging.info(f"Error auto-computing RD hours: {e}")
        return 0.0



def get_data(certificate_attendance_id, biometric_imports_id):
    """
    First get the values from database using the two IDs.
    """
    try:
        query = """
            SELECT * 
            FROM certificate_attendance 
            WHERE biometric_imports_id = %s 
            AND id = %s 
            AND approval_status = 'Approved'
        """
        data = pd.read_sql(query, engine, params=(biometric_imports_id, certificate_attendance_id))
        #print(data)  # print the retrieved data
        return data

    except Exception as e:
        print(f"Get Data Error: {type(e).__name__} – {e}")
        return None



def main(action, certificate_attendance_id, biometric_imports_id,attendance_records_id):
    try:
        """
        first get the data from the get_data then run the three function
        """
        employee_data = pd.read_sql(f"SELECT * FROM employee_management", engine)
        custom_dates_df = pd.read_sql("SELECT record_date FROM custom_dates", engine)
        non_working_days = custom_dates_df['record_date'].astype(str).tolist()
        action = "add"
        # Fetch all data
        if (action == "add"):
            df = get_data(certificate_attendance_id, biometric_imports_id)
            print(111)
            df[["Ord-OT", "Ord-ND", "Ord-ND-OT"]] = df.apply(
                autocalculate_ord,
                axis=1,
                result_type="expand",
                args=(non_working_days, employee_data, biometric_imports_id, attendance_records_id,certificate_attendance_id)
            )
            print(2222)
            df[["RD-OT", "RD-ND", "RD-ND-OT"]] = df.apply(
                autocalculate_rd_overtime,
                axis=1,
                result_type="expand",
                args=(non_working_days, employee_data, biometric_imports_id, attendance_records_id, certificate_attendance_id)
            )
            df[["RD"]] = df.apply(
                autocompute_rd,
                axis=1,
                result_type="expand",
                args=(non_working_days, employee_data, biometric_imports_id, attendance_records_id, certificate_attendance_id)
            )
            # merge_all_rd_entries(conn=conn)

        print("Done")
        # elif (action =="edit"):
        #     """
            
        #     """

        # what if edit
        

        
    except Exception as e:   # catch the exception object
        print(f"Main Error: {type(e).__name__} – {e}")



# Argument parser setup
parser = argparse.ArgumentParser(description="Process employee attendance data.")
parser.add_argument("action", type=str, help="The action",)
parser.add_argument("certificate_attendance_id", type=str, help="The certificate_attendance_id ",)
parser.add_argument("biometric_imports_id", type=str, help="The biometric_imports_id",)
parser.add_argument("attendance_records_id", type=str, help="The attendance_records_id",)

args = parser.parse_args()

# Call the main function with the provided arguments
main(
    args.action,
    args.certificate_attendance_id,
    args.biometric_imports_id,
    args.attendance_records_id,
)

