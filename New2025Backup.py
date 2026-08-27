import pandas as pd
from openpyxl import load_workbook
from openpyxl.styles import Alignment, Border, Side
import datetime
import numpy as np
import holidays
import argparse
import os
import json

# current date format of daily attendance is mm/dd/yyyy


def read_csv_files(input_csv_file, data_csv_file):
    """Reads the specified CSV files and returns DataFrames."""
    try:
        df = pd.read_csv(input_csv_file, skiprows=1)
        data = pd.read_csv(data_csv_file)
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
    """Returns a list of all Sundays in the given year formatted as mm/dd/yyyy."""
    date = datetime.date(year, 1, 1)
    date += datetime.timedelta(days=(6 - date.weekday()) % 7)
    sundays = []
    while date.year == year:
        sundays.append(date.strftime("%m/%d/%Y"))  # Format the date as mm/dd/yyyy
        date += datetime.timedelta(weeks=1)
    return sundays


def calculate_total_non_workingdays(year, custom_dates):
    """Calculates total non-working days including Sundays and holidays, formatted as mm/dd/yyyy."""
    try:
        nonworkingdays = []

        # Get Sundays and add them to the non-working days
        sundays = get_sundays(year)
        last_year = year - 1
        last_year_sundays = get_sundays(last_year)
        nonworkingdays.extend(sundays)
        nonworkingdays.extend(last_year_sundays)

        # Get holidays and format as mm/dd/yyyy
        ph_holidays = holidays.PH(years=year)
        nonworkingdays.extend(
            [holiday.strftime("%m/%d/%Y") for holiday in ph_holidays.keys()]
        )

        # Format custom dates to mm/dd/yyyy
        if custom_dates:
            formatted_customdates = [date.strftime("%m/%d/%Y") for date in custom_dates]
            nonworkingdays.extend(formatted_customdates)

        return nonworkingdays
    except Exception as ex:
        print(f"Error calculating non-working days: {ex}")


def calculate_hours_worked(df, employee_dates_list, custom_dates_list):
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
        current_year = datetime.datetime.now().year
        last_year = current_year - 1
        # Get Sundays for the current year and last year, then combine them
        sundays_current_year = get_sundays(current_year)
        sundays_last_year = get_sundays(last_year)
        sundays = sundays_last_year + sundays_current_year  # Combine lists

        # print(sundays)

        # print(custom_dates_list)

        # format is mm/dd/yyy
        non_working_days = calculate_total_non_workingdays(current_year, None)
        non_working_days += custom_dates_list
        # print(non_working_days)
        # employee_dates_list = json.loads(employee_dates)

        # Define a helper function for calculating hours worked
        def calculate_row_hours(row):

            # Check if the record exists in employee_dates_list
            employee_record = next(
                (
                    emp
                    for emp in employee_dates_list
                    if emp[1] == row["Last Name"]
                    and emp[2] == row["First Name"]
                    and emp[3] == row["Record Date"]
                ),
                None,
            )

            if employee_record:
                # If an employee record exists, override the latest and earliest times
                latest_time = pd.to_timedelta(employee_record[5])
                earliest_time = pd.to_timedelta(employee_record[4])
                print(
                    f"Employee record found for {row['Last Name']}, {row['First Name']} on {row['Record Date']}"
                )
                print(
                    f"Overridden times: Earliest Time = {earliest_time}, Latest Time = {latest_time}"
                )
            else:
                # Use the row values if no employee record exists
                print(
                    f"No employee record found for {row['Last Name']}, {row['First Name']} on {row['Record Date']}"
                )
                print("Returning default 8 hours.")
                return 8  # Default to 8 hours when no record is found

            # Check for valid times and calculate hours worked
            if pd.notna(earliest_time) and pd.notna(latest_time):
                if earliest_time <= latest_time:
                    hours = (latest_time - earliest_time).total_seconds() / 3600.0
                    print(f"Times are on the same day. Hours calculated: {hours}")
                else:
                    # Crossing midnight
                    hours = (
                        (latest_time + pd.Timedelta(hours=24)) - earliest_time
                    ).total_seconds() / 3600.0
                    print(f"Times cross midnight. Hours calculated: {hours}")

                adjusted_hours = max(
                    hours - 1, 0
                )  # Subtract 1 hour and ensure no negative hours
                print(f"Adjusted hours after subtracting 1: {adjusted_hours}")
                return adjusted_hours

            # Check if Record Date is a non-working day or Sunday
            if row["Record Date"] in non_working_days or row["Record Date"] in sundays:
                print(
                    f"Record Date {row['Record Date']} is a non-working day or Sunday."
                )
                return 0

            # General case
            if row["Earliest Time"] == row["Latest Time"]:
                print("Earliest Time and Latest Time are the same. Hours calculated: 0")
                return 0

            if row["Earliest Time"] <= row["Latest Time"]:
                # When Latest Time is greater or equal to Earliest Time
                hours = (
                    row["Latest Time"] - row["Earliest Time"]
                ).total_seconds() / 3600.0
                print(f"Row times are on the same day. Hours calculated: {hours}")
            else:
                # When Latest Time is less than Earliest Time (crossing midnight)
                hours = (
                    (row["Latest Time"] + pd.Timedelta(hours=24)) - row["Earliest Time"]
                ).total_seconds() / 3600.0
                print(f"Row times cross midnight. Hours calculated: {hours}")

            capped_hours = min(hours, 8)  # Cap at 8 hours
            print(f"Capped hours (max 8): {capped_hours}")
            return capped_hours

        # Apply the helper function to the DataFrame
        df["Hours Worked"] = df.apply(calculate_row_hours, axis=1)

        # Replace NaN or infinite values with 0
        df["Hours Worked"] = (
            df["Hours Worked"].replace([np.inf, -np.inf], np.nan).fillna(0)
        )
        # print("Test1")

        def calculate_overtime(row):
            # Check if the employee exists in the employee_dates_list
            employee_exists = any(
                row["Last Name"] == emp[1]
                and row["First Name"] == emp[2]
                and row["Record Date"] == emp[3]
                for emp in employee_dates_list
            )

            if not employee_exists:
                return 0  # No overtime if the employee record is not found

            # Calculate total hours worked
            if row["Earliest Time"] <= row["Latest Time"]:
                total_hours = (
                    row["Latest Time"] - row["Earliest Time"]
                ).total_seconds() / 3600.0
            else:
                # Crossing midnight case
                total_hours = (
                    (row["Latest Time"] + pd.Timedelta(hours=24)) - row["Earliest Time"]
                ).total_seconds() / 3600.0

            # Calculate overtime only if hours exceed 8
            overtime_hours = max(total_hours - 8, 0)

            return overtime_hours

        # Apply the function to calculate overtime
        df["Ord-OT"] = df.apply(calculate_overtime, axis=1)
        # print(df[["Earliest Time", "Latest Time", "Ord-OT"]])

        # Get Sundays for the current year

        # Calculate RD
        df["RD"] = df.apply(
            lambda row: row["Hours Worked"] if row["Record Date"] in sundays else 0,
            axis=1,
        )
        # print("RD hours calculated:")
        # print(df[["Record Date", "RD"]])

        # Calculate total non-working days present
        df["Total Non-Working Days Present"] = df.apply(
            lambda row: 1 if row["Record Date"] in non_working_days else 0,
            axis=1,
        )

        # Define night differential and night OT time ranges
        night_start = pd.to_timedelta("22:00:00")
        night_end = pd.to_timedelta("03:00:00")
        night_ot_start = pd.to_timedelta("03:00:01")
        night_ot_end = pd.to_timedelta("05:59:59")

        # Iterate through the DataFrame rows for calculation
        for index, row in df.iterrows():
            # Validate if the event is "OT" and exists in employee_dates_list
            employee_record = next(
                (
                    emp
                    for emp in employee_dates_list
                    if (
                        print(
                            f"emp[0]: {emp[0]}, emp[1]: {emp[1]} = {row["Last Name"]}, emp[2] {emp[2]} = {row["First Name"]}, emp[3] {emp[3]} = {row["Record Date"]}"
                        )
                        or True  # Print emp[0] and emp[1]
                    )
                    if emp[0] == "OT"  # Check if the event is "OT"
                    and emp[1] == row["Last Name"]
                    and emp[2] == row["First Name"]
                    and emp[3] == row["Record Date"]
                ),
                None,
            )

            # If the employee record is not found, ignore the row
            if not employee_record:
                print(f"Event is not 'OT' or employee not found for row {index}")
                # print(f"Row details: {row.to_dict()}")
                continue
            if employee_record:
                print(f"Found {index}")

            earliest = row["Earliest Time"]
            latest = row["Latest Time"]

            # Check if earliest and latest are the same; exclude from night differential
            if earliest == latest:
                df.at[index, "Ord-ND"] = 0
                df.at[index, "Ord-ND-OT"] = 0
                print(f"Excluded for night differential: Record {index}")
                continue

            # Night differential calculations
            ord_nd_hours = 0
            ord_nd_ot_hours = 0

            if earliest > latest:  # Spanning midnight (different day)
                if earliest >= night_start or earliest < night_end:
                    if latest < night_end:
                        ord_nd_hours += (
                            (night_end - earliest).total_seconds()
                        ) / 3600.0
                    else:
                        ord_nd_hours += (
                            (
                                pd.to_timedelta("24:00:00") - earliest + night_end
                            ).total_seconds()
                        ) / 3600.0

                if latest > night_ot_start and latest <= night_ot_end:
                    ord_nd_ot_hours += (
                        (latest - max(earliest, night_ot_start)).total_seconds()
                    ) / 3600.0

            else:  # Same day
                if earliest >= night_start or earliest < night_end:
                    ord_nd_hours += min(latest, night_end) - max(earliest, night_start)
                    ord_nd_hours = ord_nd_hours.total_seconds() / 3600.0

                if (latest >= night_ot_start) and (earliest <= night_ot_end):
                    ord_nd_ot_hours += (
                        (
                            min(latest, night_ot_end) - max(earliest, night_ot_start)
                        ).total_seconds()
                    ) / 3600.0

            df.at[index, "Ord-ND"] = ord_nd_hours
            df.at[index, "Ord-ND-OT"] = ord_nd_ot_hours
        #     #return df
        # print("Night Differential calculated:")
        # print(df[["Record Date", "Ord-ND", "Ord-ND-OT"]])

        # # Define RD night differential and night OT time ranges
        # rd_night_start = pd.to_timedelta("22:00:00")
        # rd_night_end = pd.to_timedelta("03:00:00")
        # rd_night_ot_start = pd.to_timedelta("03:00:01")
        # rd_night_ot_end = pd.to_timedelta("05:59:59")

        # Define RD night differential and night OT time ranges (in datetime)
        rd_night_start = datetime.strptime("22:00:00", "%H:%M:%S").time()  # 10:00 PM
        rd_night_end = datetime.strptime(
            "03:00:00", "%H:%M:%S"
        ).time()  # 3:00 AM (next day)
        rd_night_ot_start = datetime.strptime("03:00:01", "%H:%M:%S").time()
        rd_night_ot_end = datetime.strptime("05:59:59", "%H:%M:%S").time()

        # Iterate through the DataFrame rows for calculation
        for index, row in df.iterrows():
            # Validate if the event is "RD" and exists in employee_dates_list
            employee_record = next(
                (
                    emp
                    for emp in employee_dates_list
                    if emp[0] == "RD"  # Check if the event is "RD"
                    and emp[1] == row["Last Name"]
                    and emp[2] == row["First Name"]
                    and emp[3] == row["Record Date"]
                ),
                None,
            )

            # If the employee record is not found, ignore the row
            if not employee_record:
                print(
                    f"Ignored: Event is not 'RD' or employee not found for row {index}"
                )
                continue
            # if employee_record:
            #     print(f"Found {index}")
            #     # continue

            # earliest = row["Earliest Time"]
            # latest = row["Latest Time"]
            # Convert "Earliest Time" and "Latest Time" to datetime.time
            earliest = datetime.strptime(row["Earliest Time"], "%H:%M:%S").time()
            latest = datetime.strptime(row["Latest Time"], "%H:%M:%S").time()

            # Check if earliest and latest are the same; exclude from RD night differential
            if earliest == latest:
                df.at[index, "RD-ND"] = 0
                df.at[index, "RD-ND-OT"] = 0
                print(f"Excluded for RD night differential: Record {index}")
                continue

            print(1)
            print(f"Earliest: {earliest}")
            print(f"RD Night OT End: {rd_night_ot_end}")
            print(f"RD Night Start: {rd_night_start}")
            # if earliest < rd_night_ot_end or earliest >= rd_night_start:
            #     print(2)
            #     # Different Day
            #     if earliest > latest:
            #         # Check if the earliest time is before rd_night_end (within the night differential period)
            #         if earliest < rd_night_end:
            #             rd_nd_value = (rd_night_end - earliest).total_seconds() / 3600.0
            #             print(
            #                 f"RD-ND for index {index}: {rd_nd_value} hours (earliest < rd_night_end)"
            #             )
            #             df.at[index, "RD-ND"] = rd_nd_value

            #             # Calculate overtime up until rd_night_ot_end
            #             ot_end_time = min(latest, rd_night_ot_end)
            #             rd_nd_ot_value = (
            #                 ot_end_time - rd_night_ot_start
            #             ).total_seconds() / 3600.0
            #             print(
            #                 f"RD-ND-OT for index {index}: {rd_nd_ot_value} hours (overtime calculation)"
            #             )
            #             df.at[index, "RD-ND-OT"] = rd_nd_ot_value

            #         # If it surpasses rd_night_end, calculate the overtime (RD-ND-OT) time up to rd_night_ot_end
            #         elif earliest >= rd_night_ot_start:
            #             ot_end_time = min(latest, rd_night_ot_end)
            #             rd_nd_ot_value = (
            #                 ot_end_time - earliest
            #             ).total_seconds() / 3600.0
            #             print(
            #                 f"RD-ND-OT for index {index}: {rd_nd_ot_value} hours (overtime after rd_night_end)"
            #             )
            #             df.at[index, "RD-ND-OT"] = rd_nd_ot_value

            #     # Cross-day scenario (earliest > latest)
            #     elif earliest > latest:
            #         print(3)
            #         if earliest < rd_night_end:
            #             rd_nd_value = (rd_night_end - earliest).total_seconds() / 3600.0
            #             print(
            #                 f"RD-ND for index {index}: {rd_nd_value} hours (cross-day earliest < rd_night_end)"
            #             )
            #             df.at[index, "RD-ND"] = rd_nd_value

            #             # Calculate overtime
            #             ot_end_time = min(latest, rd_night_ot_end)
            #             rd_nd_ot_value = (
            #                 ot_end_time - rd_night_ot_start
            #             ).total_seconds() / 3600.0
            #             print(
            #                 f"RD-ND-OT for index {index}: {rd_nd_ot_value} hours (cross-day overtime calculation)"
            #             )
            #             df.at[index, "RD-ND-OT"] = rd_nd_ot_value
            #         elif earliest >= rd_night_ot_start:
            #             ot_end_time = min(latest, rd_night_ot_end)
            #             rd_nd_ot_value = (
            #                 ot_end_time - earliest
            #             ).total_seconds() / 3600.0
            #             print(
            #                 f"RD-ND-OT for index {index}: {rd_nd_ot_value} hours (cross-day overtime after rd_night_ot_start)"
            #             )
            #             df.at[index, "RD-ND-OT"] = rd_nd_ot_value
            #             df.at[index, "RD-ND"] = 0

        return df

    except Exception as ex:
        print(f"Error calculating hours worked: {ex}")


def group_employee_data(df):
    """Groups the employee data and calculates required fields."""
    try:
        # Filter out days where 'Hours Worked' is zero before counting them
        df["Working Day Count"] = df["Hours Worked"].apply(lambda x: 1 if x > 0 else 0)

        df_grouped = (
            df.groupby("Name")
            .agg(
                ID=("ID", "first"),
                Basic=("Basic", "first"),
                Hours_Worked=("Hours Worked", "sum"),
                Ord_OT=("Ord-OT", "sum"),
                RD=("RD", "sum"),
                RD_ND=("RD-ND", "sum"),
                RD_ND_OT=("RD-ND-OT", "sum"),
                Ord_ND=("Ord-ND", "sum"),
                Ord_ND_OT=("Ord-ND-OT", "sum"),
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

        # Convert 'Ord_OT' to 'HH:MM' format and ensure it is treated as text
        df_grouped["Ord_OT"] = df_grouped["Ord_OT"].apply(
            lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        )

        # Convert 'RD' to 'HH:MM' format
        df_grouped["RD"] = df_grouped["RD"].apply(
            lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        )
        # Convert 'RD' to 'HH:MM' format
        df_grouped["RD_ND"] = df_grouped["RD_ND"].apply(
            lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        )
        # Convert 'RD' to 'HH:MM' format
        df_grouped["RD_ND_OT"] = df_grouped["RD_ND_OT"].apply(
            lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        )

        # Convert 'Night' to 'HH:MM' format
        df_grouped["Ord_ND"] = df_grouped["Ord_ND"].apply(
            lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        )
        # Convert 'Night OT' to 'HH:MM' format
        df_grouped["Ord_ND_OT"] = df_grouped["Ord_ND_OT"].apply(
            lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        )

        # Round 'Hours_Worked' to nearest int
        df_grouped["Hours_Worked"] = df_grouped["Hours_Worked"].apply(
            lambda x: int(round(x))
        )

        return df_grouped

    except Exception as ex:
        print(f"Error grouping employee data: {ex}")
        return df  # Return the original DataFrame in case of error


def prepare_excel(df_grouped, output_excel_file):
    """Prepares the final DataFrame for Excel output with formatted headers and first row height adjustment."""
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
            "RD-OT",
            "RD-ND",
            "RD-ND-OT",
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

        # Remove underscores from headers for display in Excel
        formatted_headers = [header.replace("_", "-") for header in headers]

        # Ensure all headers are present in DataFrame
        for header in headers:
            if header not in df_grouped.columns:
                df_grouped[header] = None

        # Reorder columns to match the headers
        df_grouped = df_grouped.reindex(columns=headers)

        # # Convert specified columns to text (string) before writing to Excel
        # text_columns = ["Ord-OT", "Ord-ND", "Ord-ND-OT", "RD", "RD-OT", "RD-ND-OT"]
        # for col in text_columns:
        #     if col in df_grouped.columns:
        #         # Explicitly convert the column to string
        #         df_grouped[col] = df_grouped[col].apply(str)
        # Convert columns G to N (index 6 to 13) to text (string)
        for col_index in range(6, 14):  # Columns G to N are indices 6 to 13
            col_name = headers[col_index]
            if col_name in df_grouped.columns:
                df_grouped[col_name] = df_grouped[col_name].apply(str)
        # Write to Excel
        df_grouped.to_excel(output_excel_file, index=False, header=formatted_headers)

        # Adjust column widths, set first row height, alignment, and remove borders
        wb = load_workbook(output_excel_file)
        ws = wb.active
        ws.row_dimensions[1].height = 60  # Set height of the first row

        # Set alignment to top and remove borders for the first row
        thin_border = Border(
            left=Side(style=None),
            right=Side(style=None),
            top=Side(style=None),
            bottom=Side(style=None),
        )
        top_align = Alignment(vertical="top")

        for cell in ws[1]:
            cell.alignment = top_align
            cell.border = thin_border  # Remove border from cell

        # Apply left alignment to all rows (except headers)
        left_align = Alignment(horizontal="left")
        for row in ws.iter_rows(min_row=2, max_row=ws.max_row):
            for cell in row:
                cell.alignment = left_align

        # Auto-adjust column width based on content
        for column in ws.columns:
            max_length = 0
            column_letter = column[0].column_letter
            for cell in column:
                try:
                    if len(str(cell.value)) > max_length:
                        max_length = len(str(cell.value))
                except Exception:
                    pass
            adjusted_width = max_length + 2
            ws.column_dimensions[column_letter].width = adjusted_width

        # Save the workbook
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
    Converts a specified sheet in an Excel file to a CSV file without modifying the original Excel file.

    Parameters:
        input_excel_file (str): Path to the input Excel file.
        output_csv_file (str): Path to save the output CSV file.
        sheet_name (str or int): The sheet name or index to convert. Default is the first sheet (index 0).
    """
    try:
        # Read the specified sheet from the Excel file into a DataFrame
        df = pd.read_excel(input_excel_file, sheet_name=sheet_name)

        # Save the DataFrame to a CSV file
        df.to_csv(output_csv_file, index=False)

        print(
            f"Successfully converted '{input_excel_file}' (sheet '{sheet_name}') to '{output_csv_file}'."
        )
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
        print(f"Input CSV File: {input_csv_file}")
        print(f"Data CSV File: {data_csv_file}")
        print(f"Employee Dates File: {employee_dates_file}")
        print(f"Custom Dates File: {custom_dates_file}")
        print(f"Output Directory: {output_directory}")

        # Read employee dates and custom dates from the provided JSON files
        with open(employee_dates_file, "r") as f:
            employee_dates = json.load(f)

        with open(custom_dates_file, "r") as f:
            custom_dates = json.load(f)

        print(f"Employee Dates (Parsed): {employee_dates}")
        print(f"Custom Dates (Parsed): {custom_dates}")

        # Create output directory if it doesn't exist
        os.makedirs(output_directory, exist_ok=True)

        # Hardcoded output filenames
        output_excel_file = "output3.xlsx"
        output_csv_file = "output3.csv"

        # Full paths for output files
        output_excel_path = os.path.join(output_directory, output_excel_file)
        output_csv_path = os.path.join(output_directory, output_csv_file)

        # Reading and processing CSV files
        df, data = read_csv_files(input_csv_file, data_csv_file)
        if df is None or data is None:
            print("Failed to read CSV files.")
            return

        # Preprocessing names, merging data, calculating hours, etc.
        df, data = preprocess_names(df, data)
        df = merge_dataframes(df, data)
        df = calculate_hours_worked(df, employee_dates, custom_dates)
        df_grouped = group_employee_data(df)

        # Preparing the output Excel and CSV files
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
