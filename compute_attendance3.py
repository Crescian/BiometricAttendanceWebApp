import pandas as pd
from openpyxl import load_workbook
from openpyxl.styles import Alignment, Border, Side,Font
import datetime
import numpy as np
import holidays
import argparse
import os
import json
import math
import threading
import tempfile
import csv
from openpyxl.utils import get_column_letter, column_index_from_string
# current date format of daily attendance is mm/dd/yyyy

# Shared result variable
conversion_result = None

def convert_file(input_csv_file,output_directory):
    """Start the conversion process in a separate thread."""
    global conversion_result
    thread = threading.Thread(target=perform_conversion, args=(input_csv_file,output_directory))
    thread.start()
    thread.join()  # Wait for the thread to finish before proceeding
    return conversion_result  # Return the result after the thread finishes


# def perform_conversion(file_path, output_directory):
#     """
#     Converts input Excel or CSV file to a formatted CSV.
#     Adds Earliest, Latest, Punch time columns.
#     Skips 1 row.
#     Returns the path to the saved CSV file.
#     """
#     global conversion_result
#     try:
#         if not os.path.exists(file_path):
#             print("Input file does not exist.")
#             return None

#         # 1) Load Excel or CSV, skipping first row
#         if file_path.lower().endswith(('.xls', '.xlsx')):
#             df = pd.read_excel(file_path, skiprows=1)
#         else:
#             try:
#                 df = pd.read_csv(file_path, skiprows=1, encoding='utf-8-sig')
#             except UnicodeDecodeError:
#                 df = pd.read_csv(file_path, skiprows=1, encoding='ISO-8859-1')

#         if df.empty:
#             print("File is empty after skipping the first row.")
#             return None

#         # 2) Parse the timestamp & drop any NaT rows
#         df["Attendance time"] = pd.to_datetime(df["Attendance time"], errors="coerce")
#         df = df.dropna(subset=["Attendance time"])

#         # 3) Derive a simple date for grouping (calendar date of the punch)
#         df["DateOnly"] = df["Attendance time"].dt.date

#         # 4) Group BY ID & date, preserve file order (no sort)
#         grouped = df.groupby(["Personnel ID", "DateOnly"], sort=False)

#         records = []
#         for _, group in grouped:
#             # ensure group is in original file order
#             group = group.sort_index()

#             first_punch = group.iloc[0]["Attendance time"]
#             last_punch  = group.iloc[-1]["Attendance time"]

#             # base your output row on that first‐punch record
#             row = group.iloc[0].copy()

#             # Record Date is the date of the first punch
#             row["Record Date"] = f"'{first_punch.strftime('%Y-%m-%d')}'"

#             # Fill Earliest / Latest / Punch
#             if len(group) == 1:
#                 row["Earliest Time"] = first_punch.strftime('%H:%M:%S')
#                 row["Latest Time"]   = first_punch.strftime('%H:%M:%S')
#                 row["Punch Time"]    = first_punch.strftime('%H:%M:%S')
#             else:
#                 row["Earliest Time"] = first_punch.strftime('%H:%M:%S')
#                 row["Latest Time"]   = last_punch.strftime('%H:%M:%S')
#                 row["Punch Time"]    = (
#                     f"{first_punch:%H:%M:%S};{last_punch:%H:%M:%S}"
#                 )

#             records.append(row)

#         df_processed = pd.DataFrame(records)
#         df_processed.drop(columns=["DateOnly"], inplace=True)

#         # 5) Write out the CSV
#         header_row = ["Daily Attendance"] * 15
#         cols = [
#             "Personnel ID", "First Name", "Last Name", "Department Name", "Attendance Area",
#             "Serial Number", "Attendance Point Name", "Attendance time", "Verification Mode",
#             "Attendance Photo", "Data Sources", "Record Date", "Earliest Time", "Latest Time", "Punch Time"
#         ]
#         final_file_path = os.path.join(output_directory, "ConvertedFile.csv")
#         with open(final_file_path, 'w', newline='', encoding='utf-8-sig') as f:
#             writer = csv.writer(f)
#             writer.writerow(header_row)
#             writer.writerow(cols)
#             for _, row in df_processed.iterrows():
#                 out = []
#                 for c in cols:
#                     if c == "Record Date" and c in row:
#                         out.append(f" {row[c]}")  # leading space to force text
#                     else:
#                         out.append(row.get(c, ""))
#                 writer.writerow(out)

#         print(f"File successfully converted and saved to: {final_file_path}")
#         conversion_result = final_file_path
#         return final_file_path

#     except Exception as e:
#         print(f"Error converting file: {e}")
#         return None

def perform_conversion(file_path, output_directory):
    """
    Converts input Excel or CSV file to a formatted CSV.
    Adds Earliest, Latest, Punch time columns based on file order:
    - First punch row → Latest Time
    - Last punch row  → Earliest Time
    Skips 1 row.
    Returns the path to the saved CSV file.
    """
    global conversion_result
    try:
        if not os.path.exists(file_path):
            print("Input file does not exist.")
            return None

        # 1) Load Excel or CSV, skipping first row
        if file_path.lower().endswith(('.xls', '.xlsx')):
            df = pd.read_excel(file_path, skiprows=1)
        else:
            try:
                df = pd.read_csv(file_path, skiprows=1, encoding='utf-8-sig')
            except UnicodeDecodeError:
                df = pd.read_csv(file_path, skiprows=1, encoding='ISO-8859-1')

        if df.empty:
            print("File is empty after skipping the first row.")
            return None

        # 2) Parse the timestamp & drop any NaT rows
        df["Attendance time"] = pd.to_datetime(df["Attendance time"], errors="coerce")
        df = df.dropna(subset=["Attendance time"])

        # 3) Derive a simple date for grouping
        df["DateOnly"] = df["Attendance time"].dt.date

        # 4) Group BY ID & date, preserve file order (no sort)
        grouped = df.groupby(["Personnel ID", "DateOnly"], sort=False)

        records = []
        for _, group in grouped:
            # ensure group is in original file order
            group = group.sort_index()

            # file-order punches
            first_punch = group.iloc[0]["Attendance time"]
            last_punch  = group.iloc[-1]["Attendance time"]
            row         = group.iloc[0].copy()

            # Record Date (always from first punch)
            row["Record Date"] = f"'{first_punch.strftime('%Y-%m-%d')}'"

            # Fill Earliest / Latest based on file order
            if len(group) == 1:
                # only one punch → both earliest and latest are that time
                earliest = latest = first_punch
                punch_str = first_punch.strftime('%H:%M:%S')
            else:
                # first row is the latest, last row is the earliest
                latest   = first_punch
                earliest = last_punch

                # build punch-time string in file order, handle overnight
                p1, p2 = first_punch, last_punch
                if p2 <= p1:
                    p2 += pd.Timedelta(days=1)
                punch_str = f"{p1:%H:%M:%S};{p2:%H:%M:%S}"

            row["Earliest Time"] = earliest.strftime('%H:%M:%S')
            row["Latest Time"]   = latest.strftime('%H:%M:%S')
            row["Punch Time"]    = punch_str

            records.append(row)

        df_processed = pd.DataFrame(records)
        df_processed.drop(columns=["DateOnly"], inplace=True)

        # 5) Write out the CSV
        os.makedirs(output_directory, exist_ok=True)
        final_file_path = os.path.join(output_directory, "ConvertedFile.csv")

        header_row = ["Daily Attendance"] * 15
        cols = [
            "Personnel ID", "First Name", "Last Name", "Department Name", "Attendance Area",
            "Serial Number", "Attendance Point Name", "Attendance time", "Verification Mode",
            "Attendance Photo", "Data Sources", "Record Date", "Earliest Time", "Latest Time", "Punch Time"
        ]

        with open(final_file_path, 'w', newline='', encoding='utf-8-sig') as f:
            writer = csv.writer(f)
            writer.writerow(header_row)
            writer.writerow(cols)
            for _, row in df_processed.iterrows():
                out = []
                for c in cols:
                    if c == "Record Date" and c in row:
                        out.append(f" {row[c]}")  # leading space to force text
                    else:
                        out.append(row.get(c, ""))
                writer.writerow(out)

        print(f"File successfully converted and saved to: {final_file_path}")
        conversion_result = final_file_path
        return final_file_path

    except Exception as e:
        print(f"Error converting file: {e}")
        return None



def read_csv_files(input_csv_file,data_csv_file):
    """Reads the specified CSV files and returns DataFrames."""
    try:
        # Read the CSV files with the specified encoding
        df = pd.read_csv(input_csv_file, skiprows=1, encoding="utf-8-sig")
        data = pd.read_csv(data_csv_file, encoding="utf-8-sig")

        # df = pd.read_csv(input_csv_file, skiprows=1)
        # data = pd.read_csv(data_csv_file)

        # df = pd.read_csv(input_csv_file, skiprows=1)
        # data = pd.read_csv(data_csv_file)
        #print(df, data)
        return df, data
    except Exception as ex:
        print(f"Error reading CSV files: {ex}")
        return None, None  # Return None in case of error


def preprocess_names(df, data):
    """Preprocesses the 'Name' column in both DataFrames and replaces matching names in df with those in data."""
    try:
        df["Name"] = df["Last Name"].str.strip() + ", " + df["First Name"].str.strip()
        data["Name"] = data["Name"].str.strip()
        df["Short Name"] = df["Name"].str.split().str[:2].str.join(" ")
        name_mapping = dict(
            zip(data["Name"].str.split().str[:2].str.join(" "), data["Name"])
        )
        df["Name"] = df["Short Name"].replace(name_mapping)
        df.drop(columns=["Short Name"], inplace=True)
        return df, data
    except Exception as ex:
        print(f"Error preprocessing names: {ex}")
        return df, data  # Return the original DataFrames in case of error


def merge_dataframes(df, data):
    """Merges the attendance DataFrame with the biometric data DataFrame."""
    try:
        df = df.merge(
            data[["Name", "ID", "Basic"]],
            on="Name",
            how="left",
        )
        return df
    except Exception as ex:
        print(f"Error merging DataFrames: {ex}")
        return df  # Return the original DataFrame in case of error


def get_sundays(year):
    """Returns a list of all Sundays in the given year formatted as yyyy-mm-dd."""
    date = datetime.date(year, 1, 1)
    date += datetime.timedelta(days=(6 - date.weekday()) % 7)
    sundays = []
    while date.year == year:
        sundays.append(date.strftime("%Y-%m-%d"))  # Format the date as yyyy-mm-dd
        date += datetime.timedelta(weeks=1)
    return sundays

def calculate_total_non_workingdays(year, custom_dates):
    """Calculates total non-working days including Sundays and holidays, formatted as yyyy-mm-dd."""
    try:
        nonworkingdays = []

        # Get Sundays and add them to the non-working days
        sundays = get_sundays(year)
        last_year = year - 1
        last_year_sundays = get_sundays(last_year)
        nonworkingdays.extend(sundays)
        nonworkingdays.extend(last_year_sundays)

        # Get holidays and format as yyyy-mm-dd
        ph_holidays = holidays.PH(years=year)
        nonworkingdays.extend(
            [holiday.strftime("%Y-%m-%d") for holiday in ph_holidays.keys()]
        )

        # Format custom dates to yyyy-mm-dd
        if custom_dates:
            formatted_customdates = [date.strftime("%Y-%m-%d") for date in custom_dates]
            nonworkingdays.extend(formatted_customdates)
        #print(nonworkingdays)
        return nonworkingdays
    except Exception as ex:
        print(f"Error calculating non-working days: {ex}")


def log_overtime_to_json(
    row,
    ord_ot, rd_ot,
    ord_nd, ord_nd_ot,
    rd_nd, rd_nd_ot,
    rd, total_non_working_days_present,
    late, late_hours, late_minutes,
    out_time_required,
    type_
):
    json_file_path = "overtime_logs.json"

    # build the new data dict
    new_entry = {
        "id": row.get("ID", "N/A"),
        "name": f"{row.get('Last Name','').strip()}, {row.get('First Name','').strip()}",
        "record_date": row.get("Record Date","").replace("'", "").strip(),
        "Earliest Time": str(row.get("Earliest Time","N/A")),
        "Latest Time":   str(row.get("Latest Time","N/A")),
        "ORD-OT":   ord_ot,
        "RD-OT":    rd_ot,
        "Ord-ND":   ord_nd,
        "Ord-ND-OT":ord_nd_ot,
        "RD-ND":    rd_nd,
        "RD-ND-OT": rd_nd_ot,
        "RD":       rd,
        "Total Non-Working Days Present": total_non_working_days_present,
        "late":         late,
        "late_hours":   late_hours,
        "late_minutes": late_minutes,
        "out_time_required": out_time_required,
        "Type":      type_,
    }

    # load existing data (or start fresh)
    if os.path.exists(json_file_path):
        with open(json_file_path, "r+", encoding="utf-8") as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError:
                data = []
            # look for an existing entry with matching key fields
            match_idx = None
            for i, e in enumerate(data):
                if (
                    e.get("id")           == new_entry["id"] and
                    e.get("name")         == new_entry["name"] and
                    e.get("record_date")  == new_entry["record_date"] and
                    e.get("Earliest Time")== new_entry["Earliest Time"] and
                    e.get("Latest Time")  == new_entry["Latest Time"] and
                    e.get("Type")         == new_entry["Type"]
                ):
                    match_idx = i
                    break

            if match_idx is not None:
                # merge: overwrite only the computed fields
                data[match_idx].update(new_entry)
            else:
                data.append(new_entry)

            # rewrite the file
            f.seek(0)
            f.truncate()
            json.dump(data, f, indent=4)
    else:
        # no file yet — create it with a single entry
        with open(json_file_path, "w", encoding="utf-8") as f:
            json.dump([new_entry], f, indent=4)


def calculate_hours_worked(df, employee_dates_list, custom_dates_list, data):
    """Calculates hours worked, ORD-OT, RD, and Night Differential."""
    try:
        # Convert the time columns to timedelta
        df["Earliest Time"] = pd.to_timedelta(df["Earliest Time"], errors="coerce")
        df["Latest Time"] = pd.to_timedelta(df["Latest Time"], errors="coerce")
        # Initialize 'Ord-ND' with a default value of 0
        df["Ord-ND"] = 0
        df["Ord-ND-OT"] = 0
        df["RD-ND"] = 0
        df["RD-ND-OT"] = 0
        df["RegNDExcess"] = 0
        current_year = datetime.datetime.now().year
        last_year = current_year - 1
        # Get Sundays for the current year and last year, then combine them
        sundays_current_year = get_sundays(current_year)
        sundays_last_year = get_sundays(last_year)
        sundays = sundays_last_year + sundays_current_year  # Combine lists
       
        non_working_days = calculate_total_non_workingdays(current_year, None)
        
        non_working_days += sundays
        non_working_days += custom_dates_list
        
        # def calculate_row_hours(row):
            # try:
            #     """
            #     Indicate the TOTAL hours worked for the period EXCLUDING overtime hours and hours rendered during HOLIDAYS (AND HOLIDAY PAY), RESTDAYS or during NIGHT SHIFT - these should be distributed in the appropriate fields as defined below
            #     """
            #     # 1) Clean data
            #     last_name   = row["Last Name"].strip()
            #     first_name  = row["First Name"].strip()
            #     record_date = row["Record Date"].replace("'", "").strip()

            #     # 2) Skip non‐working days
            #     cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
            #     if record_date in cleaned_non_working_days:
            #         return 0

            #     # 3) Lookup schedule
            #     employee_name = f"{last_name}, {first_name}"
            #     match = data[data["Name"] == employee_name]
            #     if match.empty:
            #         return 0
            #     schedule = match.iloc[0]["Schedule"].strip()

            #     # 4) Determine late‐cutoff (for rounding up arrivals)
            #     if schedule == "7-4":
            #         late_cutoff = pd.to_timedelta("07:15:00")
            #     elif schedule == "8-5":
            #         late_cutoff = pd.to_timedelta("08:15:00")
            #     else:
            #         late_cutoff = pd.to_timedelta("08:15:00")

            #     # 5) Parse the raw punches
            #     in_str  = str(row.get("Earliest Time", "")).strip()
            #     out_str = str(row.get("Latest Time",  "")).strip()
            #     if not in_str or not out_str:
            #         return 0
            #     in_td   = pd.to_timedelta(in_str,  errors="coerce")
            #     out_td  = pd.to_timedelta(out_str, errors="coerce")
            #     date_base = pd.to_datetime(record_date, format="%Y-%m-%d", errors="coerce")
            #     in_time   = date_base + in_td
            #     out_time  = date_base + out_td

            #     # 6) Round up late arrivals
            #     late_threshold = date_base + late_cutoff
            #     if in_time > late_threshold:
            #         in_time = in_time.floor("H") + pd.Timedelta(hours=1)

            #     # 7) Validate and handle cross‐midnight
            #     if pd.isna(in_time) or pd.isna(out_time) or in_time >= out_time:
            #         return 0
            #     if out_time <= in_time:
            #         out_time += pd.Timedelta(days=1)

            #     # 8) Compute raw worked interval
            #     raw_worked = out_time - in_time

            #     # 9) Subtract any overlap with night shift window (22:00–06:00)
            #     midnight      = date_base + pd.Timedelta(days=1)
            #     nd_window_1   = (date_base + pd.Timedelta("22:00:00"), midnight)
            #     nd_window_2   = (midnight, midnight + pd.Timedelta("06:00:00"))

            #     def overlap(a0, a1, b0, b1):
            #         start = max(a0, b0)
            #         end   = min(a1, b1)
            #         return max(pd.Timedelta(0), end - start)

            #     nd_overlap = overlap(in_time, out_time, *nd_window_1) \
            #             + overlap(in_time, out_time, *nd_window_2)

            #     effective_worked = raw_worked - nd_overlap

            #     # 10) Subtract 1‐hour lunch break
            #     total_worked = effective_worked - pd.Timedelta(hours=1)
            #     if total_worked < pd.Timedelta(0):
            #         return 0

            #     # 11) Cap at 8 hours
            #     normal_hours = min(total_worked, pd.Timedelta("8:00:00"))

            #     # 12) Return as float hours (2 decimals)
            #     return round(normal_hours.total_seconds() / 3600, 2)

            # except Exception as ex:
            #     print(f"Error calculating row hours: {ex}")
            #     return 0

        def calculate_row_hours(row):
            try:
                # 1) Clean data
                last_name   = row["Last Name"].strip()
                first_name  = row["First Name"].strip()
                record_date = row["Record Date"].replace("'", "").strip()

                # 2) Skip non‐working days
                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
                if record_date in cleaned_non_working_days:
                    return 0.0
                
                earliest_time = row["Earliest Time"]  # Timedelta since midnight
                latest_time   = row.get("Latest Time", pd.Timedelta("00:00:00"))
                if earliest_time == latest_time:
                    return 0.0

                # 3) Lookup schedule (for late cutoff)
                employee_name = f"{last_name}, {first_name}"
                match = data[data["Name"] == employee_name]
                if match.empty:
                    return 0.0
                schedule = match.iloc[0]["Schedule"].strip()

                # 4) Determine late‐cutoff (for morning rounding)
                late_cutoff = pd.to_timedelta("07:15:00") if schedule == "7-4" else pd.to_timedelta("08:15:00")

                # 5) Parse the raw punches
                in_str  = str(row.get("Earliest Time", "")).strip()
                out_str = str(row.get("Latest Time",  "")).strip()
                if not in_str or not out_str:
                    return 0.0

                in_td  = pd.to_timedelta(in_str,  errors="coerce")
                out_td = pd.to_timedelta(out_str, errors="coerce")
                if pd.isna(in_td) or pd.isna(out_td):
                    return 0.0

                date_base = pd.to_datetime(record_date, format="%Y-%m-%d", errors="coerce")
                in_time   = date_base + in_td
                out_time  = date_base + out_td

                # 6) Round up true morning lates only
                morning_limit  = date_base + pd.Timedelta("12:00:00")
                late_threshold = date_base + late_cutoff
                # if date_base <= in_time < morning_limit and in_time > late_threshold:
                #     in_time = in_time.floor("H") + pd.Timedelta(hours=1)
                if date_base <= in_time < morning_limit and in_time > late_threshold:
                    delta = in_time - late_threshold
                    if delta < pd.Timedelta(hours=1):
                        in_time = in_time.floor("H") + pd.Timedelta(hours=1)

                # 7) Handle cross‐midnight before rejecting
                if pd.isna(in_time) or pd.isna(out_time):
                    return 0.0
                if out_time <= in_time:
                    out_time += pd.Timedelta(days=1)
                if in_time == out_time:
                    return 0.0

                # 8) Define ND window and base limit
                nd_start   = pd.to_timedelta("22:00:00")
                nd_end     = pd.to_timedelta("06:00:00")
                base_limit = pd.to_timedelta("09:00:00")

                # 9) Walk through each 1-hour block, count only non-ND in the first 9 hours
                worked_base      = pd.Timedelta(0)
                non_nd_base_time = pd.Timedelta(0)
                current = in_time

                while current < out_time and worked_base < base_limit:
                    next_hour = min(current + pd.Timedelta(hours=1), out_time)
                    block     = next_hour - current

                    # only count up to the 9h base limit
                    block_for_base = min(block, base_limit - worked_base)
                    worked_base   += block_for_base

                    tod    = current.time()
                    tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                    is_nd  = (tod_td >= nd_start) or (tod_td < nd_end)

                    if not is_nd:
                        non_nd_base_time += block_for_base

                    current = next_hour

                # 10) Subtract 1-hour lunch
                worked_minus_lunch = non_nd_base_time - pd.Timedelta(hours=1)
                if worked_minus_lunch <= pd.Timedelta(0):
                    return 0.0

                # 11) Cap at 8 hours
                straight_hours = min(worked_minus_lunch, pd.Timedelta("8:00:00"))

                # 12) Return as float hours (2 decimals)
                return round(straight_hours.total_seconds() / 3600, 2)

            except Exception as ex:
                print(f"Error calculating row hours: {ex}")
                return 0.0 
        # Apply the helper function to the DataFrame
        df["Hours Worked"] = df.apply(calculate_row_hours, axis=1)

        # Replace NaN or infinite values with 0
        df["Hours Worked"] = (
            df["Hours Worked"].replace([np.inf, -np.inf], np.nan).fillna(0)
        )
  


        def calculate_ord(row):
            try:
                # 1) Clean & parse key fields
                last_name   = row["Last Name"].strip()
                first_name  = row["First Name"].strip()
                record_date = row["Record Date"].replace("'", "").strip()

                # 2) Skip non-working days
                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
                if record_date in cleaned_non_working_days:
                    return [0, 0, 0]

                earliest_time = row["Earliest Time"]
                latest_time   = row.get("Latest Time", pd.Timedelta("00:00:00"))
                if earliest_time == latest_time:
                    return [0, 0, 0]

                # 3) Find the matching ORD record
                matching_record = next(
                    (
                        emp for emp in employee_dates_list
                        if emp[0].strip() == "ORD"
                        and emp[1].strip() == last_name
                        and emp[2].strip() == first_name
                        and emp[3].strip() == record_date
                    ),
                    None
                )
                if matching_record is None:
                    return [0, 0, 0]

                # 4) Lookup schedule for the employee
                employee_name = f"{last_name}, {first_name}"
                sched_df = data[data["Name"] == employee_name]
                if sched_df.empty:
                    return [0, 0, 0]
                schedule = sched_df.iloc[0]["Schedule"].strip()

                if schedule == "7-4":
                    start_required    = pd.to_timedelta("07:00:00")
                    late_cutoff       = pd.to_timedelta("07:15:00")
                else:
                    start_required    = pd.to_timedelta("08:00:00")
                    late_cutoff       = pd.to_timedelta("08:15:00")

                # 5) Build in_time / out_time
                date_base = pd.to_datetime(record_date, format="%Y-%m-%d")
                in_time  = pd.to_datetime(f"{record_date} {matching_record[4]}", format="%Y-%m-%d %H:%M:%S")
                out_time = pd.to_datetime(f"{record_date} {matching_record[5]}", format="%Y-%m-%d %H:%M:%S")

                # 6) Late punch check (like in autocalculate_ord)
                late = False
                morning_limit = date_base + pd.Timedelta("12:00:00")
                if date_base <= in_time < morning_limit and earliest_time > late_cutoff:
                    delta = earliest_time - start_required
                    late = True
                    if delta < pd.Timedelta(hours=1):
                        in_time = in_time.floor("H") + pd.Timedelta(hours=1)

                # 7) Handle cross-midnight
                if out_time <= in_time:
                    out_time += pd.Timedelta(days=1)
                if in_time == out_time:
                    return [0, 0, 0]

                # 8) Prepare counters
                ord_nd    = pd.Timedelta(0)
                ord_ot    = pd.Timedelta(0)
                ord_nd_ot = pd.Timedelta(0)
                worked    = pd.Timedelta(0)

                nd_start   = pd.to_timedelta("22:00:00")
                nd_end     = pd.to_timedelta("06:00:00")
                base_hours = pd.to_timedelta("09:00:00")

                # 9) Walk through each 1-hour block
                current = in_time
                while current < out_time:
                    next_hour = min(current + pd.Timedelta(hours=1), out_time)
                    block     = next_hour - current

                    tod    = current.time()
                    tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                    is_nd  = tod_td >= nd_start or tod_td < nd_end

                    if worked < base_hours:
                        worked += block
                        if is_nd:
                            ord_nd += block
                    else:
                        if is_nd:
                            ord_nd_ot += block
                        else:
                            ord_ot += block

                    current = next_hour

                # 10) Return results
                return [
                    round(ord_ot.total_seconds() / 3600, 2),
                    round(ord_nd.total_seconds() / 3600, 2),
                    round(ord_nd_ot.total_seconds() / 3600, 2),
                ]

            except Exception as ex:
                print(f"Error calculating ORD overtime: {ex}")
                return [0, 0, 0]
        #print("RD OT Flag")
        # def calculate_rd_overtime(row):
        #     try:
        #         """
        #         Calculate RD-OT, RD-ND, RD-ND-OT if the row matches employee_dates_list.
        #         """
        #         # First, check total duration from in_time to out_time.
        #         # Base working hours are up to 9 hours — anything beyond that is considered overtime (Ord-OT).
        #         # For each hourly block between in_time and out_time:
        #         #   - If it's within the first 9 hours:
        #         #       → Count as regular work time.
        #         #       → If within Night Differential window (10 PM to 6 AM), count as Ord-ND.
        #         #   - If it exceeds 9 hours:
        #         #       → Count as overtime (Ord-OT).
        #         #       → If also within Night Differential window, count as Ord-ND-OT.

        #         # Clean data
        #         last_name = row["Last Name"].strip()
        #         first_name = row["First Name"].strip()
        #         record_date = row["Record Date"].replace("'", "").strip()

        #         # Ensure this is a non-working day, otherwise skip
        #         cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
        #         if record_date not in cleaned_non_working_days:
        #             #print("TT")
        #             return [0, 0, 0]

        #         # Find matching employee record
        #         matching_record = next(
        #             (
        #                 emp for emp in employee_dates_list
        #                 if emp[0].strip() == "RD"
        #                 and emp[1].strip() == last_name
        #                 and emp[2].strip() == first_name
        #                 and emp[3].strip() == record_date
        #             ),
        #             None
        #         )
                

        #         if matching_record is None:
        #             return [0,0,0,]  # Not in employee_dates_list → skip

        #         employee_name = f"{last_name}, {first_name}"
                
        #         # Get employee schedule
        #         match = data[data["Name"] == employee_name]
        #         if match.empty:
        #             return [0,0,0,]  # No schedule data

        #         schedule = match.iloc[0]["Schedule"].strip()
        #         earliest_time = row["Earliest Time"]
        #         latest_time = row.get("Latest Time", pd.to_timedelta("00:00:00"))

        #         # Determine shift settings
        #         if schedule == "7-4":
        #             start_required = pd.to_timedelta("07:00:00")
        #             late_cutoff = pd.to_timedelta("07:15:00")
        #         elif schedule == "8-5":
        #             start_required = pd.to_timedelta("08:00:00")
        #             late_cutoff = pd.to_timedelta("08:15:00")
        #         else:
        #             start_required = pd.to_timedelta("08:00:00")
        #             late_cutoff = pd.to_timedelta("08:15:00")

        #         # Detect lateness
        #         late = earliest_time > late_cutoff
        #         late_hours = late_minutes = 0
        #         if late:
        #             total_late = earliest_time - start_required
        #             late_hours = total_late.components.hours
        #             late_minutes = total_late.components.minutes

        #         # Compute time in/out
        #         in_time = pd.to_datetime(f"{record_date} {matching_record[4]}", format="%Y-%m-%d %H:%M:%S")
        #         out_time = pd.to_datetime(f"{record_date} {matching_record[5]}", format="%Y-%m-%d %H:%M:%S")
                

        #         # Initialize counters
        #         rd_nd = pd.Timedelta(0)
        #         rd_ot = pd.Timedelta(0)
        #         rd_nd_ot = pd.Timedelta(0)
        #         worked = pd.Timedelta(0)

        #         # Set Night Differential time range
        #         nd_start = pd.to_timedelta("22:00:00")
        #         nd_end = pd.to_timedelta("06:00:00")
        #         base_hours = pd.to_timedelta("09:00:00")


        #         # Adjust for cross-midnight shift
        #         if out_time <= in_time:
        #             out_time += pd.Timedelta(days=1)

        #         # Initialize current time pointer
        #         current = in_time

        #         # Set up iteration time range
        #         # print(f"Start: {in_time}, End: {out_time}, Base Hours: {base_hours}")

        #         while current < out_time:
        #             #print(1)
        #             # Compute the end of the current block (1 hour or less)
        #             next_hour = min(current + pd.Timedelta(hours=1), out_time)
        #             block = next_hour - current

        #             # Time of day for ND check
        #             time_of_day = current.time()
        #             time_delta = pd.to_timedelta(f"{time_of_day.hour:02}:{time_of_day.minute:02}:{time_of_day.second:02}")
        #             is_nd = time_delta >= nd_start or time_delta < nd_end

        #             # print(f"\nCurrent Block: {current} to {next_hour}")
        #             # print(f"Block Duration: {block}, Is ND: {is_nd}")
        #             # print(f"Total Worked Before This Block: {worked}")

        #             if worked < base_hours:
        #                 worked += block
        #                 #print(f"--> Counted as Regular Time. Updated Worked: {worked}")
        #                 if is_nd:
        #                     rd_nd += block
        #                     #print(f"----> Also counted as Ord-ND. Total Ord-ND: {ord_nd}")
        #             else:
        #                 rd_ot += block
        #                 #print(f"--> Counted as Overtime (Ord-OT). Total Ord-OT: {ord_ot}")
        #                 if is_nd:
        #                     rd_nd_ot += block
        #                     #print(f"----> Also counted as Ord-ND-OT. Total Ord-ND-OT: {ord_nd_ot}")

        #             current = next_hour

        #         return [
        #             round(rd_ot.total_seconds() / 3600, 2),
        #             round(rd_nd.total_seconds() / 3600, 2),
        #             round(rd_nd_ot.total_seconds() / 3600, 2)
        #         ]

        #     except Exception as ex:
        #         print(f"Error calculating rd overtime: {ex}")
        #         return [0,0,0]
        def calculate_rd_overtime(row):
            try:
                # 1) Parse & clean key fields
                last_name   = row["Last Name"].strip()
                first_name  = row["First Name"].strip()
                record_date = row["Record Date"].replace("'", "").strip()

                # 2) Only on true rest-days
                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
                if record_date not in cleaned_non_working_days:
                    return [0, 0, 0]
                
                earliest_time = row["Earliest Time"]  # Timedelta since midnight
                latest_time   = row.get("Latest Time", pd.Timedelta("00:00:00"))
                if earliest_time == latest_time:
                    return [0, 0, 0]

                # 3) Find the matching RD entry
                matching_record = next(
                    (
                        emp for emp in employee_dates_list
                        if emp[0].strip() == "RD"
                        and emp[1].strip() == last_name
                        and emp[2].strip() == first_name
                        and emp[3].strip() == record_date
                    ),
                    None
                )
                if matching_record is None:
                    return [0, 0, 0]

                # 4) Lookup schedule (only to be consistent with your pattern—no late bump here)
                employee_name = f"{last_name}, {first_name}"
                sched_df = data[data["Name"] == employee_name]
                if sched_df.empty:
                    return [0, 0, 0]
                schedule = sched_df.iloc[0]["Schedule"].strip()

                # 5) Build in_time / out_time
                in_time  = pd.to_datetime(f"{record_date} {matching_record[4]}", format="%Y-%m-%d %H:%M:%S")
                out_time = pd.to_datetime(f"{record_date} {matching_record[5]}", format="%Y-%m-%d %H:%M:%S")

                # 6) Handle cross-midnight
                if out_time <= in_time:
                    out_time += pd.Timedelta(days=1)
                if in_time == out_time:
                    return [0, 0, 0]

                # 7) Prepare counters & thresholds
                rd_nd     = pd.Timedelta(0)
                rd_ot     = pd.Timedelta(0)
                rd_nd_ot  = pd.Timedelta(0)
                worked    = pd.Timedelta(0)

                nd_start   = pd.to_timedelta("22:00:00")
                nd_end     = pd.to_timedelta("06:00:00")
                base_hours = pd.to_timedelta("09:00:00")

                # 8) Block-by-block walk exactly as in autocalculate
                current = in_time
                while current < out_time:
                    next_hour = min(current + pd.Timedelta(hours=1), out_time)
                    block     = next_hour - current

                    tod    = current.time()
                    tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                    is_nd  = tod_td >= nd_start or tod_td < nd_end

                    if worked < base_hours:
                        worked += block
                        if is_nd:
                            rd_nd += block
                    else:
                        if is_nd:
                            rd_nd_ot += block
                        else:
                            rd_ot += block

                    current = next_hour

                # 9) Return as floats
                return [
                    round(rd_ot.total_seconds() / 3600, 2),
                    round(rd_nd.total_seconds() / 3600, 2),
                    round(rd_nd_ot.total_seconds() / 3600, 2),
                ]

            except Exception as ex:
                print(f"Error calculating RD overtime: {ex}")
                return [0, 0, 0]
        
       

        df[["Ord-OT", "Ord-ND", "Ord-ND-OT"]] = df.apply(calculate_ord, axis=1, result_type="expand")
        #print("ORD OT Flag")
        df[["RD-OT", "RD-ND", "RD-ND-OT"]] = df.apply(calculate_rd_overtime, axis=1, result_type="expand")
        #print("RD Flag")
        # def compute_rd(row):
        #     try:
        #         # 1) Clean up key fields
        #         record_date = row["Record Date"].replace("'", "").strip()
        #         last_name   = row["Last Name"].strip()
        #         first_name  = row["First Name"].strip()

        #         # 2) Find the matching RD entry
        #         matching_record = next(
        #             (
        #                 emp for emp in employee_dates_list
        #                 if emp[0].strip() == "RD"
        #                 and emp[1].strip() == last_name
        #                 and emp[2].strip() == first_name
        #                 and emp[3].strip() == record_date
        #             ),
        #             None
        #         )
        #         if matching_record is None:
        #             return 0

        #         # 3) Parse in/out from employee_dates_list
        #         in_time  = pd.to_datetime(
        #             f"{record_date} {matching_record[4]}",
        #             format="%Y-%m-%d %H:%M:%S", errors="coerce"
        #         )
        #         out_time = pd.to_datetime(
        #             f"{record_date} {matching_record[5]}",
        #             format="%Y-%m-%d %H:%M:%S", errors="coerce"
        #         )
        #         if pd.isna(in_time) or pd.isna(out_time) or in_time == out_time:
        #             return 0

        #         # 4) Cross‐midnight
        #         if out_time <= in_time:
        #             out_time += pd.Timedelta(days=1)

        #         # 5) Compute raw worked interval
        #         raw_worked = out_time - in_time

        #         # --- NEW: subtract any overlap with ND window (22:00–06:00) ---
        #         date_base  = pd.to_datetime(record_date, format="%Y-%m-%d")
        #         midnight   = date_base + pd.Timedelta(days=1)
        #         nd_start   = date_base + pd.Timedelta("22:00:00")
        #         nd_end     = midnight   + pd.Timedelta("06:00:00")

        #         def overlap(a0, a1, b0, b1):
        #             start = max(a0, b0)
        #             end   = min(a1, b1)
        #             return max(pd.Timedelta(0), end - start)

        #         nd_overlap = (
        #             overlap(in_time, out_time, nd_start, midnight) +
        #             overlap(in_time, out_time, midnight, nd_end)
        #         )

        #         effective_worked = raw_worked - nd_overlap
        #         if effective_worked <= pd.Timedelta(0):
        #             return 0

        #         # 6) Subtract 1h lunch
        #         post_lunch = effective_worked - pd.Timedelta(hours=1)
        #         if post_lunch <= pd.Timedelta(0):
        #             return 0

        #         # 7) Cap at 8h
        #         worked = min(post_lunch, pd.Timedelta("8:00:00"))

        #         # 8) Return hours
        #         hours = worked.total_seconds() / 3600
        #         return round(hours, 2)

        #     except Exception as e:
        #         print(f"Error in compute_rd: {e}")
        #         return 0
        def compute_rd(row):
            try:
                # 1) Pull & clean the record date
                record_date = row["Record Date"].replace("'", "").strip()
                last_name   = row["Last Name"].strip()
                first_name  = row["First Name"].strip()

                # 2) Only compute on true rest-days
                cleaned_non_working_days = [d.replace("'", "").strip() for d in non_working_days]
                if record_date not in cleaned_non_working_days:
                    return 0.0
                
                earliest_time = row["Earliest Time"]  # Timedelta since midnight
                latest_time   = row.get("Latest Time", pd.Timedelta("00:00:00"))
                if earliest_time == latest_time:
                    return 0.0

                # 3) Find the matching RD entry in employee_dates_list
                matching_record = next(
                    (
                        emp for emp in employee_dates_list
                        if emp[0].strip() == "RD"
                        and emp[1].strip() == last_name
                        and emp[2].strip() == first_name
                        and emp[3].strip() == record_date
                    ),
                    None
                )
                if matching_record is None:
                    return 0.0

                # 4) Parse in/out from the matching_record fields
                in_time  = pd.to_datetime(
                    f"{record_date} {matching_record[4]}",
                    format="%Y-%m-%d %H:%M:%S", errors="coerce"
                )
                out_time = pd.to_datetime(
                    f"{record_date} {matching_record[5]}",
                    format="%Y-%m-%d %H:%M:%S", errors="coerce"
                )
                if pd.isna(in_time) or pd.isna(out_time) or in_time == out_time:
                    return 0.0

                # 5) Handle cross-midnight
                if out_time <= in_time:
                    out_time += pd.Timedelta(days=1)

                # --- from here on, block-by-block walk just like autocompute_rd ---

                # 6) Set up ND window and base-hours limit
                nd_start_td = pd.Timedelta("22:00:00")
                nd_end_td   = pd.Timedelta("06:00:00")
                base_limit  = pd.Timedelta("09:00:00")

                worked_base      = pd.Timedelta(0)
                non_nd_base_time = pd.Timedelta(0)
                current = in_time

                while current < out_time and worked_base < base_limit:
                    next_hour      = min(current + pd.Timedelta(hours=1), out_time)
                    block          = next_hour - current
                    block_for_base = min(block, base_limit - worked_base)
                    worked_base   += block_for_base

                    tod    = current.time()
                    tod_td = pd.to_timedelta(f"{tod.hour:02}:{tod.minute:02}:{tod.second:02}")
                    is_nd  = tod_td >= nd_start_td or tod_td < nd_end_td

                    if not is_nd:
                        non_nd_base_time += block_for_base

                    current = next_hour

                # 7) Subtract 1-hour lunch
                post_lunch = non_nd_base_time - pd.Timedelta(hours=1)
                if post_lunch <= pd.Timedelta(0):
                    hours = 0.0
                else:
                    # 8) Cap at 8h
                    worked = min(post_lunch, pd.Timedelta("8:00:00"))
                    hours  = round(worked.total_seconds() / 3600, 2)

                # # 9) (Optional) log if you like, then...
                # log_overtime_to_json(
                #     row,
                #     ord_ot=0, rd_ot=0,
                #     ord_nd=0, ord_nd_ot=0,
                #     rd_nd=0, rd_nd_ot=0,
                #     rd=hours,
                #     total_non_working_days_present=0,
                #     late=False, late_hours=0, late_minutes=0,
                #     out_time_required=None,
                #     type="RD"
                # )

                return hours

            except Exception as e:
                print(f"Error in compute_rd: {e}")
                return 0.0
        df["RD"] = df.apply(compute_rd, axis=1)


        # df["RD"] = df.apply(
        #     lambda row: (
        #         print(
        #             f"RD Value: {row['Hours Worked']}"
        #         )  # Debugging print for RD value
        #         or row[
        #             "Hours Worked"
        #         ]  # Assign "Hours Worked" if all conditions below are met
        #         if any(
        #             emp[0] == "RD"  # Check if emp[0] equals "RD"
        #             and emp[1] == row["Last Name"]  # The last name matches
        #             and emp[2] == row["First Name"]  # The first name matches
        #             and emp[3] == row["Record Date"].replace("'", "").strip() # The record date matches
        #             for emp in employee_dates_list
        #         )
        #         or row["Record Date"].replace("'", "").strip()
        #         in custom_dates_list  # Record date in custom dates list
        #         else 0  # Assign 0 if conditions are not met
        #     ),
        #     axis=1,  # Apply this logic row by row
        # )
        # #print("TOTAL NON FLAG")
        # Calculate Total Non-Working Days Present
        df["Total Non-Working Days Present"] = df.apply(
            lambda row: (
                1  # Add 1 if the conditions below are met
                if any(
                    emp[1] == row["Last Name"]  # The last name matches
                    and emp[2] == row["First Name"]  # The first name matches
                    and emp[3] == row["Record Date"].replace("'", "").strip()  # The record date matches
                    and emp[0] == "RD"  # emp[0] equals "RD"
                    for emp in employee_dates_list  # Iterate through employee_dates_list
                )
                or row["Record Date"].replace("'", "").strip()
                in custom_dates_list  # Or the record date is in custom_dates_list
                else 0  # If neither condition is met, assign 0
            ),
            axis=1,  # Apply row by row
        )

               
        
        return df

    except Exception as ex:
        print(f"Error calculating hours worked: {ex}")


def group_employee_data(df, custom_dates_list):
    """Groups the employee data and calculates required fields."""
    try:
        current_year = datetime.datetime.now().year
        last_year = current_year - 1
        # Get Sundays for the current year and last year, then combine them
        sundays_current_year = get_sundays(current_year)
        sundays_last_year = get_sundays(last_year)
        sundays = sundays_last_year + sundays_current_year  # Combine lists

        # print(sundays)

        # print(custom_dates_list)

        # All dates should be in yyyy-mm-dd format
        non_working_days = calculate_total_non_workingdays(current_year, None)
        non_working_days += sundays
        non_working_days += custom_dates_list
        
        # Ensure all dates in non_working_days are in YYYY-MM-DD format
        formatted_non_working_days = []
        for date_str in non_working_days:
            try:
                # Try to parse the date string and convert to YYYY-MM-DD format
                date_obj = datetime.datetime.strptime(date_str, '%m/%d/%Y')
                formatted_non_working_days.append(date_obj.strftime('%Y-%m-%d'))
            except ValueError:
                # If the date is already in YYYY-MM-DD format, keep it as is
                formatted_non_working_days.append(date_str)
        
        non_working_days = formatted_non_working_days
        #print("All non-working days in YYYY-MM-DD format:", non_working_days)
        
        # Convert non_working_days to a set for faster lookups
        non_working_days_set = set(non_working_days)
        # Filter out days where 'Hours Worked' is zero or the date is in non_working_days
        df["Working Day Count"] = df.apply(
            lambda row: (
                1
                if row["Hours Worked"] > 0
                and row["Record Date"].replace("'", "").strip() not in non_working_days_set
                else 0
            ),
            axis=1,
        )
        

       
        print(2)
        df_grouped = (
            df.groupby("Name")
            .agg(
                ID=("ID", "first"),
                Basic=("Basic", "first"),
                Hours_Worked=("Hours Worked", "sum"),
                Ord_OT=("Ord-OT", "sum"),
                RD=("RD", "sum"),
                RD_OT=("RD-OT", "sum"),
                RD_ND=("RD-ND", "sum"),
                RD_ND_OT=("RD-ND-OT", "sum"),
                Ord_ND=("Ord-ND", "sum"),
                Ord_ND_OT=("Ord-ND-OT", "sum"),
                RegNDExcess=("RegNDExcess", "sum"),
                Total_Regular_Working_Days_Present=("Working Day Count", "sum"),
                Total_Non_Working_Days_Present=("Total Non-Working Days Present", "sum"),
            )
            .reset_index()
        )
        print(1)
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

        # Total Hours Worked → HH:MM
        df_grouped["Hours_Worked"] = df_grouped["Hours_Worked"].apply(
            lambda x: f"{int(x):02d}:{int(round((x - int(x)) * 60)):02d}"
        )

        

        return df_grouped

    except Exception as ex:
        print(f"Error grouping employee data: {ex}")
        return df  # Return the original DataFrame in case of error




def prepare_excel(df_grouped, output_excel_file):
    """Prepares the final DataFrame for Excel output with formatted text, borders, wrap, and alignment."""
    try:
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
        print(f"Error preparing Excel output: {ex}")




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
        print(f"Error preparing CSV output: {ex}")


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


def main(
    input_csv_file,
    data_csv_file,
    employee_dates_file,
    custom_dates_file,
    output_directory,
):
    """Main function to orchestrate the employee data processing."""
    try:
        # print(f"Input CSV File: {input_csv_file}")
        # print(f"Data CSV File: {data_csv_file}")
        # print(f"Employee Dates File: {employee_dates_file}")
        # print(f"Custom Dates File: {custom_dates_file}")
        # print(f"Output Directory: {output_directory}")

        # Read employee dates and custom dates from the provided JSON files
        with open(employee_dates_file, "r") as f:
            employee_dates = json.load(f)

        with open(custom_dates_file, "r") as f:
            custom_dates = json.load(f)
            
        # Ensure custom_dates are in YYYY-MM-DD format
        formatted_custom_dates = []
        for date_str in custom_dates:
            try:
                # Try to parse the date string and convert to YYYY-MM-DD format
                date_obj = datetime.datetime.strptime(date_str, '%m/%d/%Y')
                formatted_custom_dates.append(date_obj.strftime('%Y-%m-%d'))
            except ValueError:
                # If the date is already in YYYY-MM-DD format, keep it as is
                formatted_custom_dates.append(date_str)
        
        custom_dates = formatted_custom_dates
        #print("Formatted custom dates:", custom_dates)

        # Create output directory if it doesn't exist
        os.makedirs(output_directory, exist_ok=True)

        # Hardcoded output filenames
        output_excel_file = "payroll file.xlsx"
        output_csv_file = "payroll file.csv"

        # Full paths for output files
        output_excel_path = os.path.join(output_directory, output_excel_file)
        output_csv_path = os.path.join(output_directory, output_csv_file)

        # convert File to CSV and Format before 
        input_csv_file = convert_file(input_csv_file,output_directory)

        # print(f"Input CSV File: {input_csv_file}")
        # Reading and processing CSV files
        df, data = read_csv_files(input_csv_file, data_csv_file)
        df, data = read_csv_files(input_csv_file, data_csv_file)

        if df is None or data is None:
            # print("Failed to read CSV files.")
            return

        # # Preprocessing names, merging data, calculating hours, etc.
        df, data = preprocess_names(df, data)
        df = merge_dataframes(df, data)
        df = calculate_hours_worked(df, employee_dates, custom_dates, data)
        df_grouped = group_employee_data(df, custom_dates)

        # # Preparing the output Excel and CSV files
        prepare_excel(df_grouped, output_excel_path)
        excel_to_csv(output_excel_path, output_csv_path)

    except Exception as ex:
        print(f"Error in main: {ex}")


# Argument parser setup
parser = argparse.ArgumentParser(description="Process employee attendance data.")
parser.add_argument(
    "input_csv_file", type=str, help="The path to the main employee input CSV file"
)
parser.add_argument(
    "data_csv_file", type=str, help="The path to the biometric attendance CSV file"
)
parser.add_argument(
    "employee_dates_file",
    type=str,
    help="The path to the JSON file containing employee dates",
)
parser.add_argument(
    "custom_dates_file",
    type=str,
    help="The path to the JSON file containing custom dates",
)
parser.add_argument(
    "output_directory", type=str, help="The directory where output files will be saved"
)

args = parser.parse_args()

# Call the main function with the provided arguments
main(
    args.input_csv_file,
    args.data_csv_file,
    args.employee_dates_file,
    args.custom_dates_file,
    args.output_directory,
)


# test command 
# python .\compute_attendance.py '.\Test File Convert.xls' .\BiometricAttendanceInfo.csv .\employee_dates.json .\custom_dates.json .\testdir\