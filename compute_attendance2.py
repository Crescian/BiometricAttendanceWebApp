import pandas as pd
from openpyxl import load_workbook
from openpyxl.styles import Alignment, Border, Side
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
from openpyxl import load_workbook
from openpyxl.styles import Alignment, Border, Side
from openpyxl.utils import get_column_letter
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


def perform_conversion(file_path, output_directory):
    """
    Converts input Excel or CSV file to a formatted CSV.
    Adds Earliest, Latest, Punch time columns.
    Skips 1 row.
    Returns the path to the saved CSV file.
    """
    global conversion_result
    try:
        if not os.path.exists(file_path):
            print("Input file does not exist.")
            return None

        # Step 1: Load Excel or CSV
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

        # Step 2: Sort and group data
        # First convert Attendance time to datetime, ensuring proper parsing of dates
        df["Attendance time"] = pd.to_datetime(df["Attendance time"], errors='coerce')
        df = df.dropna(subset=["Attendance time"])
        df_sorted = df.sort_values(by=["Personnel ID", "Attendance time"], ascending=False)
        df_sorted["DateOnly"] = df_sorted["Attendance time"].dt.date

        grouped = df_sorted.groupby(["Personnel ID", "DateOnly"])
        records = []

        for _, group in grouped:
            group = group.sort_values("Attendance time")
            earliest = group.iloc[0]["Attendance time"]
            latest = group.iloc[-1]["Attendance time"]

            row = group.iloc[-1].copy()  # Use latest for consistency

            # Add Record Date column in YYYY-MM-DD format
            row["Record Date"] = f"'{earliest.strftime('%Y-%m-%d')}'"  # Format date as YYYY-MM-DD with quotes
            #print(f"Record Date being set: {row['Record Date']} from attendance time: {earliest}")
            
            # Set Earliest, Latest, and Punch Time
            if len(group) == 1:
                row["Earliest Time"] = earliest.strftime('%H:%M:%S')
                row["Latest Time"] = earliest.strftime('%H:%M:%S')
                row["Punch Time"] = earliest.strftime('%H:%M:%S')
            else:
                row["Earliest Time"] = earliest.strftime('%H:%M:%S')
                row["Latest Time"] = latest.strftime('%H:%M:%S')
                row["Punch Time"] = f"{earliest.strftime('%H:%M:%S')};{latest.strftime('%H:%M:%S')}"

            records.append(row)

        df_processed = pd.DataFrame(records)
        df_processed.drop(columns=["DateOnly"], inplace=True)
        

        # Step 3: Define the correct column order (with Record Date added before Earliest Time)
        header_row = ["Daily Attendance"] * 1  # Extend header row to match number of columns
        column_names = [
            "Personnel ID", "First Name", "Last Name", "Department Name", "Attendance Area", 
            "Serial Number", "Attendance Point Name", "Attendance time", "Verification Mode", 
            "Attendance Photo", "Data Sources", "Record Date", "Earliest Time", "Latest Time", "Punch Time"
        ]

        # Step 4: Save to desktop as CSV with correct format
        #desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")
        final_file_path = os.path.join(output_directory, "ConvertedFile.csv")

        # Write to CSV manually to control headers and rows
        with open(final_file_path, mode='w', newline='', encoding='utf-8-sig') as file:
            writer = csv.writer(file)
            
            # Write the header row (first row with "Daily Attendance" in each column)
            writer.writerow(header_row)
            
            # Write the column names (second row with actual column headers)
            writer.writerow(column_names)
            
            # Write the processed data rows
            for _, row in df_processed.iterrows():
                # Create a list of values, handling the Record Date column specially
                row_values = []
                for col in column_names:
                    if col == "Record Date" and col in row:
                        # Add a space before the date to force it as text without quotes
                        row_values.append(f" {row[col]}")
                    else:
                        row_values.append(row[col] if col in row else '')
                writer.writerow(row_values)

        print(f"File successfully converted and saved to: {final_file_path}")
        conversion_result = final_file_path  # Set the global result
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


# Add this function earlier in your script
def log_overtime_to_json(row,ord_ot,rd_ot,ord_nd,ord_nd_ot,rd_nd,rd_nd_ot,rd,total_non_working_days_present, late, late_hours, late_minutes, out_time_required, type):
    json_file_path = "overtime_logs.json"

    log_entry = {
        "id": row.get("ID", "N/A"),
        "name": f"{row.get('Last Name', '').strip()}, {row.get('First Name', '').strip()}",
        "record_date": row.get("Record Date", "").replace("'", "").strip(),
        "Earliest Time": str(row.get("Earliest Time", "N/A")),
        "Latest Time": str(row.get("Latest Time", "N/A")),
        "ORD-OT": ord_ot,
        # "Ord-OT": round(row.get("Ord-OT", 0), 2),
        "RD-OT": round(row.get("RD-OT", 0), 2),
        "Ord-ND": round(row.get("Ord-ND", 0), 2),
        "Ord-ND-OT": round(row.get("Ord-ND-OT", 0), 2),
        "RD-ND": round(row.get("RD-ND", 0), 2),
        "RD-ND-OT": round(row.get("RD-ND-OT", 0), 2),
        "RD (Rest Day Present)": round(row.get("RD", 0), 2),
        "Total Non-Working Days Present": round(row.get("Total Non-Working Days Present", 0), 2),
        "Type": type,
        # New computed values
        "late": late,
        "late_hours": late_hours,
        "late_minutes": late_minutes,
        "out_time_required": out_time_required,
    }

    if os.path.exists(json_file_path):
        with open(json_file_path, "r+", encoding="utf-8") as file:
            try:
                data = json.load(file)
            except json.JSONDecodeError:
                data = []
            data.append(log_entry)
            file.seek(0)
            json.dump(data, file, indent=4)
    else:
        with open(json_file_path, "w", encoding="utf-8") as file:
            json.dump([log_entry], file, indent=4)

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
        # print(sundays)

        #print(custom_dates_list)
        # No need to convert custom_dates_list since it should already be in YYYY-MM-DD format
        #print(custom_dates_list)
        non_working_days = calculate_total_non_workingdays(current_year, None)
        #print(2)
        non_working_days += sundays
        non_working_days += custom_dates_list
        #print(3)
        # print("test",non_working_days)
        # All dates should already be in yyyy-mm-dd format at this point
        #print("test2",non_working_days)
        #print(1)


        # print(non_working_days)
        # employee_dates_list = json.loads(employee_dates)
        #print(non_working_days)
        def calculate_row_hours(row):
            try:
                # Check if the record exists in employee_dates_list
                employee_record = next(
                    (
                        emp
                        for emp in employee_dates_list
                        if emp[1] == row["Last Name"]
                        and emp[2] == row["First Name"]
                        and emp[3] == row["Record Date"].replace("'", "").strip()
                    ),
                    None,
                )

                record_date = row["Record Date"]
                #print(f"Raw record_date value: '{record_date}'")

                record_date = record_date.replace("'", "").strip()
                #print(f"Cleaned record_date value: '{record_date}'")


                


                for non_working_day in non_working_days:
                    non_working_day = non_working_day.replace("'", "").strip()
                    #print(f"Comparing record_date: {record_date} with non_working_day: {non_working_day}")
                    
                    if record_date == non_working_day and not employee_record:
                        # print("TESTTTTTTTTTTTTTTTTTT") 
                        # print(f"Record Date {record_date} is a non-working day or Sunday and no employee record exists")
                        # print(f"employee_record value: {employee_record}")
                        return 0
                
                
                # Validate earliest and latest times
                if pd.isna(row["Earliest Time"]) or pd.isna(row["Latest Time"]):
                    # print("Invalid Earliest Time or Latest Time. Hours calculated: 0")
                    return 0

                # Handle case where Earliest Time and Latest Time are the same
                if row["Earliest Time"] == row["Latest Time"]:
                    # print("Earliest Time and Latest Time are the same. Hours calculated: 0")
                    return 0
                earliest_time = pd.to_timedelta(row["Earliest Time"])
                latest_time = pd.to_timedelta(row["Latest Time"])
                # Handle Late Cases
                # variable for late time
                
                # get value from biometric
                # if ( == )
                # print(type(data))
                # print(type(str(data['Schedule']))
                employee_name =  row["Last Name"]+", "+row["First Name"]
                #print(employee_name)
                # print(row["First Name"])
                
                # Find matching schedule
                match = data[data["Name"] == employee_name]
                print(type(row["Earliest Time"]))
                print(row["Earliest Time"])

                if not match.empty:
                    schedule = match.iloc[0]["Schedule"]
                    print("Schedule:", schedule)

                    if schedule.strip() == "7-4":
                        # Compare Timedelta (Earliest Time) to 7:15 AM
                        late_cutoff = pd.to_timedelta("07:15:00")
                        replace_time = pd.to_timedelta("08:00:00")

                        if earliest_time > late_cutoff:
                            earliest_time  = replace_time
                            print(earliest_time)

                    elif  schedule.strip() == "8-5":
                        # Compare Timedelta (Earliest Time) to 7:15 AM
                       
                        late_cutoff = pd.to_timedelta("08:15:00")
                        replace_time = pd.to_timedelta("09:00:00")

                        if earliest_time > late_cutoff:
                            earliest_time  = replace_time
                else:
                    print("No matching employee found.")
                

                
                if employee_record:
                    # Override times if employee record exists
                    latest_time = pd.to_timedelta(employee_record[5])
                    earliest_time = pd.to_timedelta(employee_record[4])
                    # print(
                    #     f"Employee record found for {row['Last Name']}, {row['First Name']} on {row['Record Date']}"
                    # )
                    # print(
                    #     f"Overridden times: Earliest Time = {earliest_time}, Latest Time = {latest_time}"
                    # )
                
               

                # Calculate hours worked
                if pd.notna(earliest_time) and pd.notna(latest_time):
                    if earliest_time <= latest_time:
                        # Times are on the same day
                        hours = (latest_time - earliest_time).total_seconds() / 3600.0
                        # print(f"Times are on the same day. Hours calculated: {hours}")
                    else:
                        # Times cross midnight
                        hours = (
                            (latest_time + pd.Timedelta(hours=24)) - earliest_time
                        ).total_seconds() / 3600.0
                        # print(f"Times cross midnight. Hours calculated: {hours}")

                    # Subtract 1 hour for breaks (if applicable) and ensure non-negative hours
                    adjusted_hours = max(hours - 1, 0)
                    print("Adjusted hours:", adjusted_hours)
                    # print(f"Adjusted hours after subtracting 1: {adjusted_hours}")

                    # Cap hours to 8 if no employee record is found
                    if not employee_record and adjusted_hours > 8:
                        adjusted_hours = 8
                        # print(f"Capped hours for non-employee record: {adjusted_hours}")

                    # If less than 8, return the rounded value using round()
                    if adjusted_hours < 8:
                        rounded_hours = round(adjusted_hours)
                        print("Less than 8 hours:", rounded_hours)
                        return rounded_hours

                    # Otherwise, round and return using round()
                    rounded_hours = round(adjusted_hours)
                    print(rounded_hours)
                    return rounded_hours

                return 0
            except Exception as ex:
                print(f"Error calculating row hours: {ex}")
                return 0

        # Apply the helper function to the DataFrame
        df["Hours Worked"] = df.apply(calculate_row_hours, axis=1)

        # Replace NaN or infinite values with 0
        df["Hours Worked"] = (
            df["Hours Worked"].replace([np.inf, -np.inf], np.nan).fillna(0)
        )
        # print("Test1")

        def calculate_overtime(row):
            try:
                record_date = row["Record Date"].replace("'", "").strip()
                # Check if the employee exists in the employee_dates_list
                employee_exists = any(
                    emp[0] == "ORD"  # Ensure emp[0] is "ORD"
                    and row["Last Name"] == emp[1]
                    and row["First Name"] == emp[2]
                    and row["Record Date"].replace("'", "").strip() == emp[3]
                    for emp in employee_dates_list
                )
                # Find the matching employee record
                matching_record = next(
                    (
                        emp
                        for emp in employee_dates_list
                        if row["Last Name"].strip() == emp[1].strip()
                        and row["First Name"].strip() == emp[2].strip()
                        and record_date == emp[3].strip().replace("'", "")
                    ),
                    None,
                )

                if not employee_exists:
                    return 0  # No overtime if the employee record is not found
                
                employee_name = row["Last Name"] + ", " + row["First Name"]
                match = data[data["Name"] == employee_name]
                if not match.empty:
                    schedule = match.iloc[0]["Schedule"].strip()
                    earliest_time = row["Earliest Time"]
                    latest_time = row.get("Latest Time", pd.to_timedelta("00:00:00"))

                    # Define schedule-based cutoff
                    if schedule == "7-4":
                        start_required = pd.to_timedelta("07:00:00")
                        late_cutoff = pd.to_timedelta("07:15:00")
                        out_time_required = "16:00"
                    elif schedule == "8-5":
                        start_required = pd.to_timedelta("08:00:00")
                        late_cutoff = pd.to_timedelta("08:15:00")
                        out_time_required = "17:00"
                    else:
                        # Default for unknown schedule
                        start_required = pd.to_timedelta("08:00:00")
                        late_cutoff = pd.to_timedelta("08:15:00")
                        out_time_required = "17:00"

                    # Late detection
                    late = False
                    late_hours = 0
                    late_minutes = 0

                    if earliest_time > late_cutoff:
                        late = True
                        total_late = earliest_time - start_required
                        late_hours = total_late.components.hours
                        late_minutes = total_late.components.minutes

                    # Compute late status
                    late = earliest_time > late_cutoff
                    late_hours = 0
                    late_minutes = 0
                    if late:
                        total_late = earliest_time - start_required
                        late_hours = total_late.components.hours
                        late_minutes = total_late.components.minutes

                    # Compute dynamic out time (9 hours after in)
                    out_time_required = earliest_time + pd.to_timedelta("09:00:00")
                    out_time_required_str = str(out_time_required).split()[-1][:8]

                   
                # else:
                #     print("No matching employee found.")
                #     return row

                
                # Extract in/out times from matching record
                # Convert in_time and out_time to Timedelta (same type as row["Latest Time"])
                in_time = pd.to_datetime(f"{record_date} {matching_record[4]}", format="%Y-%m-%d %H:%M:%S")
                out_time = pd.to_datetime(f"{record_date} {matching_record[5]}", format="%Y-%m-%d %H:%M:%S")


                

                # Calculate Timedelta
                in_time_timedelta = in_time - pd.to_datetime(f"{record_date} 00:00:00", format="%Y-%m-%d %H:%M:%S")
                out_time_timedelta = out_time - pd.to_datetime(f"{record_date} 00:00:00", format="%Y-%m-%d %H:%M:%S")

                # check if late is true if out_time_required is greater than out_time delta return 0 like if out_time is 16:15:00 and out_time_delta is 16:13:00
                if (late == True and out_time_required > out_time_timedelta ):
                    return 0


                # Calculate total hours based on matching record
                if in_time_timedelta <= out_time_timedelta:
                    total_hours = (out_time_timedelta - in_time_timedelta).total_seconds() / 3600.0
                else:
                    # Crossing midnight case
                    total_hours = ((out_time_timedelta + pd.Timedelta(hours=24)) - in_time_timedelta).total_seconds() / 3600.0
                
                if total_hours < 9:
                    log_overtime_to_json(row,total_hours,0,0,0,0,0,0,0, late, late_hours, late_minutes, out_time_required_str,"ORD")
                    return 0  # Do not compute overtime if work hours are less than 9
                    
                # Calculate overtime only if hours exceed 9
                overtime_hours = max(total_hours - 9, 0)

                #log_overtime_to_json(row, late, late_hours, late_minutes, out_time_required_str, "ORD")
                #log_overtime_to_json(row,overtime_hours,rd_ot,ord_nd,ord_nd_ot,rd_nd,rd_nd_ot,rd,total_non_working_days_present, late, late_hours, late_minutes, out_time_required,"ORD")
                log_overtime_to_json(row,overtime_hours,0,0,0,0,0,0,0, late, late_hours, late_minutes, out_time_required_str,"ORD")

                return overtime_hours
            except Exception as ex:
                print(f"Error calculating overtime: {ex}")
                return 0

        def calculate_rd_overtime(row):
            try:
                # Clean record_date
                record_date = row["Record Date"].replace("'", "").strip()

                # Check if the employee exists in the employee_dates_list
                employee_exists = any(
                    row["Last Name"].strip() == emp[1].strip()
                    and row["First Name"].strip() == emp[2].strip()
                    and record_date == emp[3].strip().replace("'", "")
                    for emp in employee_dates_list
                )

                # Find the matching employee record
                matching_record = next(
                    (
                        emp
                        for emp in employee_dates_list
                        if row["Last Name"].strip() == emp[1].strip()
                        and row["First Name"].strip() == emp[2].strip()
                        and record_date == emp[3].strip().replace("'", "")
                    ),
                    None,
                )

                if not employee_exists or matching_record is None:
                    return 0  # No overtime if the employee record is not found

                employee_name = row["Last Name"] + ", " + row["First Name"]
                match = data[data["Name"] == employee_name]
                if not match.empty:
                    schedule = match.iloc[0]["Schedule"].strip()
                    earliest_time = row["Earliest Time"]
                    latest_time = row.get("Latest Time", pd.to_timedelta("00:00:00"))

                    # Define schedule-based cutoff
                    if schedule == "7-4":
                        start_required = pd.to_timedelta("07:00:00")
                        late_cutoff = pd.to_timedelta("07:15:00")
                        out_time_required = "16:00"
                    elif schedule == "8-5":
                        start_required = pd.to_timedelta("08:00:00")
                        late_cutoff = pd.to_timedelta("08:15:00")
                        out_time_required = "17:00"
                    else:
                        # Default for unknown schedule
                        start_required = pd.to_timedelta("08:00:00")
                        late_cutoff = pd.to_timedelta("08:15:00")
                        out_time_required = "17:00"

                    # Late detection
                    late = False
                    late_hours = 0
                    late_minutes = 0

                    if earliest_time > late_cutoff:
                        late = True
                        total_late = earliest_time - start_required
                        late_hours = total_late.components.hours
                        late_minutes = total_late.components.minutes

                    # Compute late status
                    late = earliest_time > late_cutoff
                    late_hours = 0
                    late_minutes = 0
                    if late:
                        total_late = earliest_time - start_required
                        late_hours = total_late.components.hours
                        late_minutes = total_late.components.minutes

                    # Compute dynamic out time (9 hours after in)
                    out_time_required = earliest_time + pd.to_timedelta("09:00:00")
                    out_time_required_str = str(out_time_required).split()[-1][:8]

                # Use the date from the matching record
                record_date = matching_record[3].strip().replace("'", "")

                # Check if the record date is a non-working day
                if record_date not in non_working_days:
                    return 0

                # Extract in/out times from matching record
                # Convert in_time and out_time to Timedelta (same type as row["Latest Time"])
                in_time = pd.to_datetime(f"{record_date} {matching_record[4]}", format="%Y-%m-%d %H:%M:%S")
                out_time = pd.to_datetime(f"{record_date} {matching_record[5]}", format="%Y-%m-%d %H:%M:%S")

                # Calculate Timedelta
                # in_time_timedelta = in_time - pd.to_datetime("2025-03-09 00:00:00", format="%Y-%m-%d %H:%M:%S")
                # out_time_timedelta = out_time - pd.to_datetime("2025-03-09 00:00:00", format="%Y-%m-%d %H:%M:%S")

                # Calculate Timedelta
                in_time_timedelta = in_time - pd.to_datetime(f"{record_date} 00:00:00", format="%Y-%m-%d %H:%M:%S")
                out_time_timedelta = out_time - pd.to_datetime(f"{record_date} 00:00:00", format="%Y-%m-%d %H:%M:%S")

                # Now in_time_timedelta and out_time_timedelta will be of type Timedelta
                # print(f"in_time_timedelta: {in_time_timedelta}")
                # print(f"out_time_timedelta: {out_time_timedelta}")
                # print(f"Type of in_time_timedelta: {type(in_time_timedelta)}")
                # print(f"Type of out_time_timedelta: {type(out_time_timedelta)}")
                # #print(f"Type of in_time_timedelta: {type(row["Latest Time"])}")

                # Calculate total hours based on matching record
                if in_time_timedelta <= out_time_timedelta:
                    total_hours = (out_time_timedelta - in_time_timedelta).total_seconds() / 3600.0
                else:
                    # Crossing midnight case
                    total_hours = ((out_time_timedelta + pd.Timedelta(hours=24)) - in_time_timedelta).total_seconds() / 3600.0

                if total_hours < 9:
                    log_overtime_to_json(row,total_hours,0,0,0,0,0,0,0, late, late_hours, late_minutes, out_time_required_str,"ORD")
                    return 0  # Do not compute overtime if work hours are less than 9
                        
        
                #log_overtime_to_json(row, late, late_hours, late_minutes, out_time_required_str, "ORD")
                #log_overtime_to_json(row,overtime_hours,rd_ot,ord_nd,ord_nd_ot,rd_nd,rd_nd_ot,rd,total_non_working_days_present, late, late_hours, late_minutes, out_time_required,"ORD")
                
                # Calculate overtime only if hours exceed 9
                #print(f"Total Hours {total_hours}")
                overtime_hours = max(total_hours - 9, 0)
                log_overtime_to_json(row,overtime_hours,0,0,0,0,0,0,0, late, late_hours, late_minutes, out_time_required_str,"ORD")
                # subtract all the additional hours from Hours Worked
                


                
                #print(f"overtime Hours {overtime_hours}")
                return overtime_hours
            except Exception as ex:
                print(f"Error calculating rd overtime: {ex}")
                return 0

        # Apply the function to calculate overtime
        df["Ord-OT"] = df.apply(calculate_overtime, axis=1)

        # Apply the function to calculate overtime
        df["RD-OT"] = df.apply(calculate_rd_overtime, axis=1)

        

        
        df["RD"] = df.apply(
            lambda row: (
                print(
                    f"RD Value: {row['Hours Worked']}"
                )  # Debugging print for RD value
                or row[
                    "Hours Worked"
                ]  # Assign "Hours Worked" if all conditions below are met
                if any(
                    emp[0] == "RD"  # Check if emp[0] equals "RD"
                    and emp[1] == row["Last Name"]  # The last name matches
                    and emp[2] == row["First Name"]  # The first name matches
                    and emp[3] == row["Record Date"].replace("'", "").strip() # The record date matches
                    for emp in employee_dates_list
                )
                or row["Record Date"].replace("'", "").strip()
                in custom_dates_list  # Record date in custom dates list
                else 0  # Assign 0 if conditions are not met
            ),
            axis=1,  # Apply this logic row by row
        )

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

        # Define Ord night differential and night OT time ranges
        night_start = pd.to_timedelta("22:00:00")
        night_end = pd.to_timedelta("03:00:00")
        night_ot_start = pd.to_timedelta("03:00:01")
        night_ot_end = pd.to_timedelta("06:00:00")
        for index, row in df.iterrows():
            employee_record = next(
                (
                    emp
                    for emp in employee_dates_list
                    if emp[0] == "ORD"
                    and emp[1] == row["Last Name"]
                    and emp[2] == row["First Name"]
                    and emp[3] == row["Record Date"].replace("'", "").strip()
                ),
                None,
            )

            if not employee_record:
                # print(f"Ignored: Employee record not found for row {index}")
                continue

            earliest = pd.to_timedelta(employee_record[4])
            latest = pd.to_timedelta(employee_record[5])

            if earliest == latest:
                df.at[index, "Ord-ND"] = 0
                df.at[index, "Ord-ND-OT"] = 0
                # print(f"Excluded due to no work duration: Record {index}")
                continue

            total_nd = 0
            total_nd_ot = 0

            # Adjust for cross-day scenario
            if earliest > latest:
                latest += pd.Timedelta(days=1)

            # Calculate Ord-ND (22:00 to 03:00)
            if earliest < night_start:  # Adjust earliest before 22:00 to start at 22:00
                earliest = night_start

            nd_start = max(earliest, night_start)
            nd_end = (
                min(latest, night_end + pd.Timedelta(days=1))
                if latest > night_end
                else latest
            )

            if nd_start < nd_end:
                total_nd = (nd_end - nd_start).total_seconds() / 3600.0
                # print(f"Ord-ND for index {index}: {total_nd} hours")

            # Calculate Ord-ND-OT (03:00:01 to 06:00:00)
            ot_start = max(earliest, night_ot_start)
            ot_end = (
                min(latest, night_ot_end + pd.Timedelta(days=1))
                if latest > night_ot_end
                else latest
            )

            if ot_start < ot_end:
                total_nd_ot = (ot_end - ot_start).total_seconds() / 3600.0
                # print(f"Ord-ND-OT for index {index}: {total_nd_ot} hours")

            df.at[index, "Ord-ND"] = total_nd
            df.at[index, "Ord-ND-OT"] = total_nd_ot - total_nd


            ### CHANGE THIS ME
            df.at[index, "Earliest Time"] = earliest
            df.at[index, "Latest Time"] = latest


        # Define RD night differential and night OT time ranges
        rd_night_start = pd.to_timedelta("22:00:00")
        rd_night_end = pd.to_timedelta("03:00:00")
        rd_night_ot_start = pd.to_timedelta("03:00:00")
        rd_night_ot_end = pd.to_timedelta("06:00:00")
        for index, row in df.iterrows():
            employee_record = next(
                (
                    emp
                    for emp in employee_dates_list
                    if emp[0] == "RD"
                    and emp[1] == row["Last Name"]
                    and emp[2] == row["First Name"]
                    and emp[3] == row["Record Date"].replace("'", "").strip()
                ),
                None,
            )

            if not employee_record:
                # print(f"Ignored: Employee record not found for row {index}")
                continue

            earliest = 0
            latest = 0
            earliest = pd.to_timedelta(employee_record[4])
            latest = pd.to_timedelta(employee_record[5])

            if earliest == latest:
                df.at[index, "RD-ND"] = 0
                df.at[index, "RD-ND-OT"] = 0
                # print(f"Excluded due to no work duration: Record {index}")
                continue

            total_rd_nd = 0
            total_rd_nd_ot = 0

            # Adjust for cross-day scenario
            if earliest > latest:
                latest += pd.Timedelta(days=1)

            # Calculate Ord-ND (22:00 to 03:00)
            if (
                earliest < rd_night_start
            ):  # Adjust earliest before 22:00 to start at 22:00
                earliest = rd_night_start

            rd_nd_start = max(earliest, rd_night_start)
            rd_nd_end = (
                min(latest, rd_night_end + pd.Timedelta(days=1))
                if latest > rd_night_end
                else latest
            )

            if rd_nd_start < rd_nd_end:
                total_rd_nd = (rd_nd_end - rd_nd_start).total_seconds() / 3600.0
                # print(f"RD-ND for index {index}: {total_rd_nd} hours")

            # Calculate Ord-ND-OT (03:00:01 to 06:00:00)
            rd_ot_start = max(earliest, rd_night_ot_start)
            rd_ot_end = (
                min(latest, rd_night_ot_end + pd.Timedelta(days=1))
                if latest > rd_night_ot_end
                else latest
            )

            if rd_ot_start < rd_ot_end:
                total_rd_nd_ot = (rd_ot_end - rd_ot_start).total_seconds() / 3600.0
                # print(f"RD-ND-OT for index {index}: {total_rd_nd_ot} hours")

            df.at[index, "RD-ND"] = total_rd_nd
            df.at[index, "RD-ND-OT"] = total_rd_nd_ot - total_rd_nd
             ### CHANGE THIS ME
            df.at[index, "Earliest Time"] = earliest
            df.at[index, "Latest Time"] = latest



        cols_to_subtract = ["Ord-OT","Ord-ND","Ord-ND-OT","RD","RD-OT","RD-ND-OT"]

        # build a small DataFrame of Hours Worked + those columns
        debug = df[["Hours Worked"] + cols_to_subtract].copy()

        # add a column that is the row-wise sum of the six subtractors
        debug["Total to Subtract"] = debug[cols_to_subtract].sum(axis=1)
        print("wtf")
        # print every row’s Hours Worked, each OT/ND/RD column, and the total
        print(debug.to_string(index=False))

        # now subtract and clamp
        df["Hours Worked"] = df["Hours Worked"] - debug["Total to Subtract"]
        df["Hours Worked"] = df["Hours Worked"].clip(lower=0)   
      
        

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
                Total_Non_Working_Days_Present=(
                    "Total Non-Working Days Present",
                    "sum",
                ),
            )
            .reset_index()
        )

        # # Format the 'Ord_OT' to 2 decimal places for display/export
        # df_grouped["Ord_OT"] = df_grouped["Ord_OT"].apply(lambda x: f"{x:.2f}")

        # # Convert 'Ord_OT' to 'HH:MM' format and ensure it is treated as text
        # df_grouped["Ord_OT"] = df_grouped["Ord_OT"].apply(
        #     lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        # )


        # # Round 'Hours_Worked' to nearest int
        # df_grouped["RD"] = df_grouped["RD"].apply(lambda x: int(round(x)))
        # # Convert 'RD' to 'HH:MM' format
        # df_grouped["RD_OT"] = df_grouped["RD_OT"].apply(
        #     lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        # )
        # # Convert 'RD' to 'HH:MM' format
        # df_grouped["RD_ND"] = df_grouped["RD_ND"].apply(
        #     lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        # )
        # # Convert 'RD' to 'HH:MM' format
        # df_grouped["RD_ND_OT"] = df_grouped["RD_ND_OT"].apply(
        #     lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        # )

        # # Convert 'Night' to 'HH:MM' format
        # df_grouped["Ord_ND"] = df_grouped["Ord_ND"].apply(
        #     lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        # )
        # # Convert 'Night OT' to 'HH:MM' format
        # df_grouped["Ord_ND_OT"] = df_grouped["Ord_ND_OT"].apply(
        #     lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        # )

        # # Convert 'Night' to 'HH:MM' format
        # df_grouped["RegNDExcess"] = df_grouped["RegNDExcess"].apply(
        #     lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        # )

        # # Round 'Hours_Worked' to nearest int
        # df_grouped["Hours_Worked"] = df_grouped["Hours_Worked"].apply(
        #     lambda x: int(round(x))
        # )

        # Keep all these as floats (e.g. hours with fractional part)
        numeric_cols = [
            "Ord_OT", "RD_OT", "RD_ND", "RD_ND_OT",
            "Ord_ND", "Ord_ND_OT", "RegNDExcess",
            "Hours_Worked", "RD"
        ]

        # 1) Ensure they're floats
        for col in numeric_cols:
            df_grouped[col] = df_grouped[col].astype(float)

        # 2) Optionally round to two decimals for display/export
        df_grouped["Ord_OT"]       = df_grouped["Ord_OT"].round(2)
        df_grouped["RD"]           = df_grouped["RD"].round(2)
        df_grouped["RD_OT"]        = df_grouped["RD_OT"].round(2)
        df_grouped["RD_ND"]        = df_grouped["RD_ND"].round(2)
        df_grouped["RD_ND_OT"]     = df_grouped["RD_ND_OT"].round(2)
        df_grouped["Ord_ND"]       = df_grouped["Ord_ND"].round(2)
        df_grouped["Ord_ND_OT"]    = df_grouped["Ord_ND_OT"].round(2)
        df_grouped["RegNDExcess"]  = df_grouped["RegNDExcess"].round(2)
        df_grouped["Hours_Worked"] = df_grouped["Hours_Worked"].round(2)

        return df_grouped

    except Exception as ex:
        print(f"Error grouping employee data: {ex}")
        return df  # Return the original DataFrame in case of error


# def prepare_excel(df_grouped, output_excel_file):
#     """Prepares the final DataFrame for Excel output with formatted headers and first row height adjustment."""
#     try:
#         headers = [
#             "ID",
#             "Name",
#             "Basic",
#             "Hours_Worked",
#             "Total_Regular_Working_Days_Present",
#             "Total_Non_Working_Days_Present",
#             "Ord_OT",
#             "Ord_ND",
#             "Ord_ND_OT",
#             "RegNDExcess",
#             "RD",
#             "RD_OT",
#             "RD_ND",
#             "RD_ND_OT",
#             "SunNDExcess",
#             "SH",
#             "SH-OT",
#             "SH-ND",
#             "SH-ND-OT",
#             "SHNDExcess",
#             "LH",
#             "LH-OT",
#             "LH-ND",
#             "LH-ND-OT",
#             "LHNDExcess",
#             "SH-RD",
#             "SH-RD-OT",
#             "SH-RD-ND",
#             "SH-RD-ND-OT",
#             "SHRNDExcess",
#             "LH-RD",
#             "LH-RD-OT",
#             "LH-RD-ND",
#             "LH-RD-ND-OT",
#             "LHRNDExcess",
#             "DH",
#             "DH-OT",
#             "DH-ND",
#             "DH-ND-OT",
#             "DHNDExcess",
#             "DH-RD",
#             "DH-RD-OT",
#             "DH-RD-ND",
#             "DH-RD-ND-OT",
#         ]

#         # Ensure all headers are present in DataFrame
#         for header in headers:
#             if header not in df_grouped.columns:
#                 df_grouped[header] = None

#         # Reorder columns to match the headers
#         df_grouped = df_grouped.reindex(columns=headers)

#         # Convert columns G to N (index 6 to 13) to text (string)
#         for col_index in range(6, 14):
#             col_name = headers[col_index]
#             if col_name in df_grouped.columns:
#                 df_grouped[col_name] = df_grouped[col_name].apply(str)

#         # Step 1: Format headers (replace underscores with hyphens)
#         formatted_headers = [header.replace("_", "-") for header in headers]

#         # Step 2: Apply renaming after formatting
#         excel_column_rename_map = {
#             "Total-Regular-Working-Days-Present": "Total Regular Working Days Present",
#             "Total-Non-Working-Days-Present": "Total Non-Working Days Present",
#         }
#         final_headers = [excel_column_rename_map.get(h, h) for h in formatted_headers]

#         # Write to Excel
#         df_grouped.to_excel(output_excel_file, index=False, header=final_headers)

#         # Adjust column widths, set first row height, alignment, and remove borders
#         wb = load_workbook(output_excel_file)
#         ws = wb.active
#         ws.row_dimensions[1].height = 60  # Set height of the first row

#         # Remove borders and align header row to top
#         thin_border = Border(
#             left=Side(style=None),
#             right=Side(style=None),
#             top=Side(style=None),
#             bottom=Side(style=None),
#         )
#         top_align = Alignment(vertical="top")

#         for cell in ws[1]:
#             cell.alignment = top_align
#             cell.border = thin_border

#         # Apply left alignment to all data rows
#         left_align = Alignment(horizontal="left")
#         for row in ws.iter_rows(min_row=2, max_row=ws.max_row):
#             for cell in row:
#                 cell.alignment = left_align

#         # Auto-adjust column width based on content
#         for column in ws.columns:
#             max_length = 0
#             column_letter = column[0].column_letter
#             for cell in column:
#                 try:
#                     if cell.value and len(str(cell.value)) > max_length:
#                         max_length = len(str(cell.value))
#                 except Exception:
#                     pass
#             adjusted_width = max_length + 2
#             ws.column_dimensions[column_letter].width = adjusted_width

#         # Save the workbook
#         wb.save(output_excel_file)

#     except Exception as ex:
#         print(f"Error preparing Excel output: {ex}")

def prepare_excel(df_grouped, output_excel_file):
    """Prepares the final DataFrame for Excel output with every cell explicitly formatted as Text."""
    try:
        headers = [
            "ID",
            "Name",
            "Basic",
            "Hours_Worked",
            "Total_Regular_Working_Days_Present",
            "Total_Non_Working_Days_Present",
            "Ord_OT",
            "Ord_ND",
            "Ord_ND_OT",
            "RegNDExcess",
            "RD",
            "RD_OT",
            "RD_ND",
            "RD_ND_OT",
            "SunNDExcess",
            "SH",
            "SH-OT",
            "SH-ND",
            "SH-ND-OT",
            "SHNDExcess",
            "LH",
            "LH-OT",
            "LH-ND",
            "LH-ND-OT",
            "LHNDExcess",
            "SH-RD",
            "SH-RD-OT",
            "SH-RD-ND",
            "SH-RD-ND-OT",
            "SHRNDExcess",
            "LH-RD",
            "LH-RD-OT",
            "LH-RD-ND",
            "LH-RD-ND-OT",
            "LHRNDExcess",
            "DH",
            "DH-OT",
            "DH-ND",
            "DH-ND-OT",
            "DHNDExcess",
            "DH-RD",
            "DH-RD-OT",
            "DH-RD-ND",
            "DH-RD-ND-OT",
        ]

        # 1) Ensure all headers exist, filling missing ones with empty string
        for h in headers:
            if h not in df_grouped.columns:
                df_grouped[h] = ""

        # 2) Reorder DataFrame to match the exact header order
        df_grouped = df_grouped.reindex(columns=headers)

        # 3) Convert every value to Python str
        df_grouped = df_grouped.astype(str)

        # 4) Prepare human-friendly display headers
        formatted = [h.replace("_", "-") for h in headers]
        rename = {
            "Total-Regular-Working-Days-Present": "Total Regular Working Days Present",
            "Total-Non-Working-Days-Present": "Total Non-Working Days Present",
        }
        final_headers = [rename.get(h, h) for h in formatted]

        # 5) Export via pandas
        df_grouped.to_excel(output_excel_file, index=False, header=final_headers)

        # 6) Re-open with openpyxl to lock every cell into Text format
        wb = load_workbook(output_excel_file)
        ws = wb.active

        # Style the header row
        ws.row_dimensions[1].height = 60
        top_align = Alignment(vertical="top")
        no_border = Border(
            left=Side(style=None), right=Side(style=None),
            top=Side(style=None), bottom=Side(style=None),
        )
        for cell in ws[1]:
            cell.alignment = top_align
            cell.border = no_border

        # Force every cell (including headers) to Excel Text
        text_fmt = "@"  # Excel’s code for Text
        left_align = Alignment(horizontal="left", vertical="center")

        for row in ws.iter_rows(min_row=1, max_row=ws.max_row):
            for cell in row:
                # guarantee Python-side string
                cell.value = "" if cell.value is None else str(cell.value)
                # tell Excel “this is text”
                cell.number_format = text_fmt
                cell.data_type = "s"
                # align
                cell.alignment = top_align if cell.row == 1 else left_align

        # Auto-fit columns to content
        for col in ws.columns:
            letter = get_column_letter(col[0].column)
            max_len = max((len(str(c.value)) for c in col), default=0)
            ws.column_dimensions[letter].width = max_len + 2

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