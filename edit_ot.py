import os
import sys
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
from openpyxl import load_workbook
from openpyxl.styles import Alignment, Font, Border, Side
from openpyxl.utils import get_column_letter, column_index_from_string
from autocompute_attendance import conn, engine, log_overtime_to_db, log_security_db, merge_all_rd_entries
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


def update_record(my_type, ord_ot, ord_nd, ord_nd_ot, rd, rd_ot, rd_nd, rd_nd_ot, late, late_hours, late_minutes,out_time_required ,overtime_id):
    try:
        """
        first check the type then update the fields of overtimes based
        """
        def float_to_hhmm(value):
            if value is None:
                return "00:00"
            hours = int(value)
            minutes = int(round((value - hours) * 60))
            return f"{hours:02d}:{minutes:02d}"
        ord_ot      = float_to_hhmm(ord_ot)
        ord_nd      = float_to_hhmm(ord_nd)
        ord_nd_ot   = float_to_hhmm(ord_nd_ot)
        rd          = float_to_hhmm(rd)
        rd_ot       = float_to_hhmm(rd_ot)
        rd_nd       = float_to_hhmm(rd_nd)
        rd_nd_ot    = float_to_hhmm(rd_nd_ot)
    
        print(my_type)
        with engine.begin() as conn:  # automatically commits/rolls back
            if my_type == "ord":
                query = text("""
                    UPDATE overtimes
                    SET ord_ot = :ord_ot,
                        ord_nd = :ord_nd,
                        ord_nd_ot = :ord_nd_ot,
                        late = :late,
                        late_hours = :late_hours,
                        late_minutes = :late_minutes,
                        out_time_required = :out_time_required
                    WHERE id = :overtime_id
                """)
                conn.execute(query, {
                    "ord_ot": ord_ot,
                    "ord_nd": ord_nd,
                    "ord_nd_ot": ord_nd_ot,
                    "late": late,
                    "late_hours": late_hours,
                    "late_minutes": late_minutes,
                    "out_time_required": out_time_required,
                    "overtime_id": overtime_id
                })

            elif my_type == "rd":
                query = text("""
                    UPDATE overtimes
                    SET rd = :rd,
                        late = :late,
                        late_hours = :late_hours,
                        late_minutes = :late_minutes,
                        out_time_required = :out_time_required
                    WHERE id = :overtime_id
                """)
                conn.execute(query, {
                    "rd": rd,
                    "late": late,
                    "late_hours": late_hours,
                    "late_minutes": late_minutes,
                    "out_time_required": out_time_required,
                    "overtime_id": overtime_id
                })

            elif my_type == "rd_ot":
                query = text("""
                    UPDATE overtimes
                    SET rd_ot = :rd_ot,
                        rd_nd = :rd_nd,
                        rd_nd_ot = :rd_nd_ot,
                        late = :late,
                        late_hours = :late_hours,
                        late_minutes = :late_minutes,
                        out_time_required = :out_time_required
                    WHERE id = :overtime_id
                """)
                conn.execute(query, {
                    "rd_ot": rd_ot,
                    "rd_nd": rd_nd,
                    "rd_nd_ot": rd_nd_ot,
                    "late": late,
                    "late_hours": late_hours,
                    "late_minutes": late_minutes,
                    "out_time_required": out_time_required,
                    "overtime_id": overtime_id
                })

        logging.info(f"Update success for type {my_type} and overtime_id {overtime_id}")

    except Exception as e:
        logging.info(f"Error Update: {type(e).__name__} – {e}")

def autocalculate_ord(row, non_working_days,data,item_id,edit_type, biometric_imports_id):
    try:
        
        # 1) Identify date & skip non‐working days
        record_date = str(row["record_date"]).split(" ")[0]
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
        # temp_sched_pd = pd.read_sql("""
        #     SELECT 
        #         schedule_adjustments.schedule AS temp_schedule,
        #         schedule_adjustments.record_date,
        #         employee_management.employee_name
        #     FROM schedule_adjustments
        #     INNER JOIN employee_management
        #     ON employee_management.id = schedule_adjustments.employee_management_id
        # """, engine)

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
        

        # if not temp_match.empty:
        #     # use temp schedule
        #     schedule = temp_match.iloc[0]["schedule"]
        # else:
        #     # fall back to the normal schedule table
        #     match = data[data["employee_name"] == employee_name]
        #     if match.empty:
        #         return 0.0
        #     schedule = match.iloc[0]["schedule"]
        if not temp_match.empty:
            schedule = temp_match.iloc[0]["schedule"]
            if isinstance(schedule, pd.Series):
                schedule = schedule.iloc[0]
        else:
            match = data[data["employee_name"] == employee_name]
            if match.empty:
                print(f"No match found for employee: '{employee_name}'")
                return [0, 0, 0]
            schedule = match.iloc[0]["schedule"]
            # print(f"schedule v1{schedule}")
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
                logging.info(f"Invalid or unrecognized schedule format ORD: {schedule} ({e})")
        
        # 3) Detect late (but only if punch is before noon)
        #earliest_time = row["earliest_time"]  # Timedelta since midnight
        #date_base     = pd.to_datetime(record_date, format="%Y-%m-%d")
        #date_base = pd.to_datetime(record_date, errors="coerce")
        
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
        day_shift = schedule in ("7-16", "8-17", "7-19","9-15")
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
        if schedule in ("15-23", "23-7","23-8","9-15"):
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
            #print(11)
            # Convert schedule to timedelta
            schedule_start, schedule_end = map(int, schedule.split("-"))
            scheduled_start = pd.Timedelta(hours=schedule_start)
            scheduled_end = pd.Timedelta(hours=schedule_end)
            # print(f"earliest_time:{earliest_time}")
            # print(f"latest_time:{latest_time}")
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
                if (edit_type == "schedule_adjustment"):
                    attendance_records_id = item_id
                    item_id = (
                    log_overtime_to_db(
                        conn,
                        row,
                        ord_ot=ord_ot,
                        rd_ot=0,
                        ord_nd=ord_nd,
                        ord_nd_ot=ord_nd_ot,
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
                        biometric_imports_id=biometric_imports_id,
                        attendance_records_id=attendance_records_id, schedule_shift=schedule_shift, update_target="ord")
                )



                update_record(my_type="ord",ord_ot=ord_ot, ord_nd=ord_nd, ord_nd_ot=ord_nd_ot,rd=0,rd_ot=0,rd_nd=0, rd_nd_ot=0, late=late, late_hours=late_hours, late_minutes=late_minutes,out_time_required=out_time_required ,overtime_id=item_id)
                
                return [0, 0, 0]

            else:
               
                # Non-security employees
                # if schedule adjustment insert the overtimes then get the id
                # new_overtime_id = log_overtime_to_db(conn=conn, row=row, ord_ot=ord_ot, rd_ot=0,ord_nd=ord_nd, ord_nd_ot=ord_nd_ot, rd_nd=0, rd_nd_ot=0,rd=0,total_non_working_days_present=0,late=late,late_hours=late_hours, late_minutes=late_minutes, out_time_required=out_time_required,schedule=schedule, status="Pending", biometric_imports_id= biometric_imports_id,attendance_records_id=item_id)
                # update_record("ord", ord_ot=ord_ot, ord_nd=ord_nd_ot, ord_nd_ot=ord_nd_ot, rd=0, rd_ot=0,rd_nd=0, rd_nd_ot=0,late=late,late_hours=late_hours,late_minutes=late_minutes ,overtime_id=new_overtime_id)
                if (edit_type == "schedule_adjustment"):
                    attendance_records_id = item_id
                    print(f"schedule 99{schedule}" )
                    print(attendance_records_id)
                    item_id = (
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
                        biometric_imports_id=biometric_imports_id,
                        attendance_records_id=attendance_records_id, schedule_shift=schedule_shift,update_target="ord")
                )
                print(item_id)
            
                update_record(my_type="ord",ord_ot=ord_ot, ord_nd=ord_nd, ord_nd_ot=ord_nd_ot,rd=0,rd_ot=0,rd_nd=0, rd_nd_ot=0, late=late, late_hours=late_hours, late_minutes=late_minutes,out_time_required=out_time_required,overtime_id=item_id)
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
                    logging.error(f"Error converting ORD OT return values to seconds: {conv_ex}")
                    return [0, 0, 0]
        else:
            # If no OT values, return zeros
            return [0, 0, 0]
                   
            return [
                round(ord_ot.total_seconds() / 3600, 2),
                round(ord_nd.total_seconds() / 3600, 2),
                round(ord_nd_ot.total_seconds() / 3600, 2),
            ]

    except Exception as ex:
        logging.info(f"Error auto-calculating ORD: {ex}")
        return [0, 0, 0]

def autocalculate_rd_overtime(row, non_working_days,data,item_id, edit_type, biometric_imports_id):
    try:
        
        
        # ✅ Pull temp_sched table directly from PostgreSQL
        #temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments", engine)
        temp_sched_pd = pd.read_sql("SELECT * FROM schedule_adjustments INNER JOIN employee_management ON employee_management.id = schedule_adjustments.employee_management_id", engine)

        #temp_sched_pd["employee_name"] = temp_sched_pd["last_name"].str.strip() + ", " + temp_sched_pd["first_name"].str.strip()
        #temp_sched_pd["record_date"] = temp_sched_pd["record_date"]  # normalise the column name
        record_date = str(row["record_date"]).split(" ")[0]


        cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
        if record_date not in cleaned_non_working_days:
            return [0, 0, 0]
        # earliest_time = row["earliest_time"]  # Timedelta since midnight
        # latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
        earliest_time = pd.to_timedelta(row["earliest_time"])
        latest_time = pd.to_timedelta(row.get("latest_time", "00:00:00"))
        if earliest_time == latest_time:
            return [0, 0, 0]
        #logging.info(33)
        # 2) Build actual in/out datetimes from the row’s punches
        # in_td   = row["earliest_time"]
        # out_td  = row.get("latest_time", pd.to_timedelta("00:00:00"))
        date_base = pd.to_datetime(record_date,errors="coerce")
        in_time   = date_base + earliest_time
        out_time  = date_base + latest_time

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
                logging.info(f"Invalid or unrecognized schedule format RD OT: {schedule} ({e})")
        
        #logging.info(55)
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
        if schedule in ("15-23", "23-7","23-8","9-15"):
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
                if (edit_type == "schedule_adjustment"):
                    attendance_records_id = item_id
                    item_id = (
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
                        biometric_imports_id=biometric_imports_id,
                        attendance_records_id=attendance_records_id, schedule_shift=schedule_shift,update_target="rd_ot")
                )



                update_record(my_type="rd_ot",ord_ot=0, ord_nd=0, ord_nd_ot=0,rd=0,rd_ot=rd_ot_val,rd_nd=rd_nd_val, rd_nd_ot=rd_nd_ot_val, late=False, late_hours=0, late_minutes=0,out_time_required=out_time_required,overtime_id=item_id)
             
                return [0, 0, 0]

            else:
                # # Non-security employees
                rd_ot_val = round(rd_ot.total_seconds() / 3600, 2)
                rd_nd_val = round(rd_nd.total_seconds() / 3600, 2)
                rd_nd_ot_val = round(rd_nd_ot.total_seconds() / 3600, 2)
                # update_record(ord_ot=0, ord_nd=0, ord_nd_ot=0, rd=0,rd_ot=rd_ot_val,rd_nd=rd_nd_val, rd_nd_ot=rd_nd_ot_val, late=False, late_hours=0, late_minutes=0, overtime_id=overtime_id)
                if (edit_type == "schedule_adjustment"):
                    attendance_records_id = item_id
                    item_id = (
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
                        biometric_imports_id=biometric_imports_id,
                        attendance_records_id=attendance_records_id, schedule_shift=schedule_shift,update_target="rd_ot")
                )
                print("NIS")



                update_record(my_type="rd_ot",ord_ot=0, ord_nd=0, ord_nd_ot=0,rd=0,rd_ot=rd_ot_val,rd_nd=rd_nd_val, rd_nd_ot=rd_nd_ot_val, late=False, late_hours=0, late_minutes=0,out_time_required=out_time_required,overtime_id=item_id)
             
            try:
                rd_ot_sec = rd_ot.total_seconds() if isinstance(rd_ot, pd.Timedelta) else 0.0
                rd_nd_sec = rd_nd.total_seconds() if isinstance(rd_nd, pd.Timedelta) else 0.0
                rd_nd_ot_sec = rd_nd_ot.total_seconds() if isinstance(rd_nd_ot, pd.Timedelta) else 0.0
                
                return [
                    round(rd_ot_sec / 3600, 2),
                    round(rd_nd_sec / 3600, 2),
                    round(rd_nd_ot_sec / 3600, 2),
                ]
            except Exception as conv_ex:
                logging.error(f"Error converting RD OT return values to seconds: {conv_ex}")
                return [0, 0, 0]
        else:
            # If no OT values, return zeros
            return [0, 0, 0]

    except Exception as ex:
        logging.info(f"Error auto‐calculating RD overtime: {ex}")
        return [0, 0, 0]


def autocompute_rd(row, non_working_days,data,item_id, edit_type, biometric_imports_id):
    try:
        #logging.info(1100)
        # 🔹 Recreate employee match here
        # last_name     = row["last_name"].strip()
        # first_name    = row["first_name"].strip()
        # 1) Pull & clean the record_date
        record_date = str(row["record_date"]).split(" ")[0]

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
        earliest_time = pd.to_timedelta(earliest_time)
        #earliest_time = pd.to_timedelta(row["earliest_time"])
        latest_time   = row.get("latest_time", pd.Timedelta("00:00:00"))
        #logging.info(1300)
        # 4) Determine late‐cutoff (for morning rounding)
        # late_cutoff = pd.to_timedelta("07:15:00") if schedule == "7-16" else pd.to_timedelta("08:15:00")
        logging.info("logging 3")
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
                logging.info(f"Invalid or unrecognized schedule format RD: {schedule} ({e})")

        #logging.info(1400)
        logging.info("logging 4")
        day_shift = schedule in ("7-16", "8-17", "7-19","6-15","9-15","10-18","10-16")
        night_shift = schedule in ("18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8")
        schedule_shift = "day shift"
        if day_shift:
            schedule_shift = "day shift"
        elif night_shift:
            schedule_shift = "night shift"
        else:
            schedule_shift = None

        # 2) Only compute on true rest-days
        if record_date not in cleaned_non_working_days:
            return 0.0
        
        
        if earliest_time == latest_time:
            return 0.0

        logging.info("999")
        # 3) Parse raw punches into timestamps
        in_td  = pd.to_timedelta(row["earliest_time"], errors="coerce")
        out_td = pd.to_timedelta(row.get("latest_time", "00:00:00"), errors="coerce")
        if pd.isna(in_td) or pd.isna(out_td):
            return 0.0
       # Convert to Timedelta if not already
        earliest_time = pd.to_timedelta(earliest_time, errors='coerce')
        latest_time   = pd.to_timedelta(latest_time, errors='coerce')
        date_base = pd.to_datetime(record_date, format="%Y-%m-%d", errors="coerce")
        in_time   = date_base + earliest_time   # ← use overridden earliest_time
        out_time  = date_base + latest_time     # ← use overridden latest_time
        late = False
        late_hours = late_minutes = 0
        morning_limit = date_base + pd.Timedelta("12:00:00")
        logging.info("9982")
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
        
        # # 6) Round up all lates
        # late_threshold = date_base + late_cutoff
        # if in_time > late_threshold:
        #     delta = in_time - late_threshold
        #     if delta < pd.Timedelta(hours=1):
        #         in_time = in_time.floor("h") + pd.Timedelta(hours=1)
        out_time = date_base + latest_time
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
                if (edit_type == "schedule_adjustment"):
                    attendance_records_id = item_id
                    item_id = (
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
                        biometric_imports_id=biometric_imports_id,
                        attendance_records_id=attendance_records_id, update_target="rd")
                )



                update_record(my_type="rd",ord_ot=0, ord_nd=0, ord_nd_ot=0,rd=hours,rd_ot=0,rd_nd=0, rd_nd_ot=0, late=False, late_hours=0, late_minutes=0,out_time_required=out_time_required,overtime_id=item_id)
                
                # update_record(ord_ot=0, ord_nd=0, ord_nd_ot=0,rd=hours,rd_ot=0,rd_nd=0, rd_nd_ot=0, late=late, late_hours=late_hours, late_minutes=late_minutes,out_time_required=out_time_required ,overtime_id=item_id)
                # log_overtime_to_db(
                #     conn,
                #     row,
                #     ord_ot=0,
                #     rd_ot=rd_val,
                #     ord_nd=0,
                #     ord_nd_ot=0,
                #     rd_nd=rd_nd_val,
                #     rd_nd_ot=rd_nd_ot_val,
                #     rd=0,
                #     total_non_working_days_present=0,
                #     late=False,
                #     late_hours=0,
                #     late_minutes=0,
                #     out_time_required=None,
                #     type="RD",
                #     schedule=schedule,
                #     status="Pending"
                # )

                # # ✅ Do NOT return any values for security
                # return
                return 0.0

            else:
                # Non-security employees
                if (edit_type == "schedule_adjustment"):
                    attendance_records_id = item_id
                    item_id = (
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
                        biometric_imports_id=biometric_imports_id,
                        attendance_records_id=attendance_records_id, schedule_shift=schedule_shift,update_target="rd")
                )
                    



                update_record(my_type="rd",ord_ot=0, ord_nd=0, ord_nd_ot=0,rd=hours,rd_ot=0,rd_nd=0, rd_nd_ot=0, late=False, late_hours=0, late_minutes=0,out_time_required=out_time_required,overtime_id=item_id)
               
            # ✅ Only return hours for non-security
            return hours

    except Exception as e:
        logging.info(f"Error auto-computing RD hours: {e}")
        return 0.0



def get_data(item_id, edit_type):
    """
    Get data from overtime or attendance table using item_id.
    """
    try:
        if edit_type == "overtimes":
            query = """
                SELECT *
                FROM overtimes
                WHERE id = %s
            """
        elif edit_type == "schedule_adjustment":
            # Inner join to employee_management to get unique_id, employee_name, schedule, status, department
            query = """
                SELECT ar.*, em.unique_id, em.employee_name, em.schedule, em.department
                FROM attendance_records ar
                INNER JOIN employee_management em ON ar.employee_management_id = em.id
                WHERE ar.id = %s
            """
        else:
            return None  # Handle unexpected edit_type safely

        data = pd.read_sql(query, engine, params=(item_id,))
        return data

    except Exception as e:
        print(f"Error in get_data: {e}")
        return None

    except Exception as e:
        print(f"get_data: {type(e).__name__} – {e}")
        return None

def main(biometric_imports_id ,item_id, edit_type):
    try:
        employee_data = pd.read_sql(f"SELECT * FROM employee_management", engine)
        custom_dates_df = pd.read_sql("SELECT record_date FROM custom_dates", engine)
        non_working_days = custom_dates_df['record_date'].astype(str).tolist()
        df = get_data(item_id, edit_type)
       
        if df is not None and not df.empty:
            row = df.iloc[0]  # Get first row since get_data returns a DataFrame
            if edit_type == "overtimes":
                if row["type"].lower() == "ord":
                    df[["Ord-OT", "Ord-ND", "Ord-ND-OT"]] = df.apply(
                        autocalculate_ord,
                        axis=1,
                        result_type="expand",
                        args=(non_working_days, employee_data, item_id,edit_type, biometric_imports_id)
                    )
                    print(1123231)

                elif row["type"].lower() == "rd":
                    df[["RD"]] = df.apply(
                        autocompute_rd,
                        axis=1,
                        result_type="expand",
                        args=(non_working_days, employee_data, item_id, edit_type, biometric_imports_id)
                    )
                    df[["RD-OT", "RD-ND", "RD-ND-OT"]] = df.apply(
                        autocalculate_rd_overtime,
                        axis=1,
                        result_type="expand",
                        args=(non_working_days, employee_data, item_id, edit_type, biometric_imports_id)
                    )
                    merge_all_rd_entries(conn=conn)
            elif edit_type == "schedule_adjustment":
                if row["weekday"].lower() != "sunday":
                    df[["Ord-OT", "Ord-ND", "Ord-ND-OT"]] = df.apply(
                        autocalculate_ord,
                        axis=1,
                        result_type="expand",
                        args=(non_working_days, employee_data, item_id,edit_type, biometric_imports_id)
                    )
                    print(1123231)

                elif row["weekday"].lower() == "sunday":
                    df[["RD"]] = df.apply(
                        autocompute_rd,
                        axis=1,
                        result_type="expand",
                        args=(non_working_days, employee_data, item_id, edit_type, biometric_imports_id)
                    )
                    df[["RD-OT", "RD-ND", "RD-ND-OT"]] = df.apply(
                        autocalculate_rd_overtime,
                        axis=1,
                        result_type="expand",
                        args=(non_working_days, employee_data, item_id, edit_type, biometric_imports_id)
                    )
                    merge_all_rd_entries(conn=conn)

        

            # else:
            #     logging.info(f"Unknown overtime type: {row['type']}")
            
        else:
            logging.info("No overtime data found for given overtime_id.")
        
    except Exception as e:   # catch the exception object
        logging.info(f"Main Error: {type(e).__name__} – {e}")


# Argument parser setup
parser = argparse.ArgumentParser(description="Process employee attendance data.")
parser.add_argument("biometric_imports_id", type=str, help="The biometric_imports_id",)
parser.add_argument("item_id", type=str, help="The either overtime or attendance_record_id",)
parser.add_argument("edit_type", type=str, help="The module used",) #schedule_adjustment or overtimes


args = parser.parse_args()

# Call the main function with the provided arguments
main(
    args.biometric_imports_id,
    args.item_id,
    args.edit_type
)


