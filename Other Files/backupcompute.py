import pandas as pd
from openpyxl import load_workbook
import datetime
import numpy as np
import holidays
import argparse

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


def calculate_total_non_workingdays(year, customdates):
    """Calculates total non-working days including Sundays and holidays, formatted as mm/dd/yyyy."""
    try:
        nonworkingdays = []

        # Get Sundays and add them to the non-working days
        sundays = get_sundays(year)
        nonworkingdays.extend(sundays)

        # Get holidays and format as mm/dd/yyyy
        ph_holidays = holidays.PH(years=year)
        nonworkingdays.extend(
            [holiday.strftime("%m/%d/%Y") for holiday in ph_holidays.keys()]
        )

        # Format custom dates to mm/dd/yyyy
        if customdates:
            formatted_customdates = [date.strftime("%m/%d/%Y") for date in customdates]
            nonworkingdays.extend(formatted_customdates)

        return nonworkingdays
    except Exception as ex:
        print(f"Error calculating non-working days: {ex}")


def calculate_hours_worked(df):
    """Calculates hours worked,ORD-OT, RD"""
    try:
        # Convert the time columns to timedelta
        df["Earliest Time"] = pd.to_timedelta(df["Earliest Time"], errors="coerce")
        df["Latest Time"] = pd.to_timedelta(df["Latest Time"], errors="coerce")
        # Initialize 'Ord-ND' with a default value of 0
        df["Ord-ND"] = 0

        # Calculate hours worked, handling non-finite values

        # Using lambda to calculate Hours Worked

        # Calculate Hours Worked with 24-hour adjustment if necessary
        df["Hours Worked"] = df.apply(
            lambda row: (
                (row["Latest Time"] - row["Earliest Time"]).total_seconds() / 3600.0
                if row["Earliest Time"] <= row["Latest Time"]
                else (
                    (row["Latest Time"] + pd.Timedelta(hours=24)) - row["Earliest Time"]
                ).total_seconds()
                / 3600.0
            ),
            axis=1,
        )

        # Replace NaN or infinite values with 0, keep as float
        df["Hours Worked"] = (
            df["Hours Worked"].replace([np.inf, -np.inf], np.nan).fillna(0)
        )

        # Calculate 'Ord-OT' based on 'Hours Worked' and keep it as a float
        df["Ord-OT"] = df["Hours Worked"].apply(lambda x: max(0, x - 7))

        # Round 'Ord-OT' to 2 decimal places
        df["Ord-OT"] = df["Ord-OT"].round(2)

        # print("Ord-OT values after calculation:")
        # print(df[["Name", "Hours Worked", "Ord-OT"]])

        # Get Sundays for the current year
        current_year = datetime.datetime.now().year
        sundays = get_sundays(current_year)
        non_working_days = calculate_total_non_workingdays(current_year, None)
        # print(non_working_days)
        # print(sundays)

        # Calculate RD hours based on whether the 'Record Date' is a Sunday
        df["RD"] = df.apply(
            lambda row: row["Hours Worked"] if row["Record Date"] in sundays else 0,
            axis=1,
        )

        df["Total Non-Working Days Present"] = df.apply(
            lambda row: 1 if row["Record Date"] in non_working_days else 0,
            axis=1,
        )

        # Night differential calculation
        night_start = pd.to_timedelta("22:00:00")
        night_end = pd.to_timedelta("06:00:00")

        for index, row in df.iterrows():
            earliest = row["Earliest Time"]
            latest = row["Latest Time"]

            # Check if earliest and latest are the same; if so, exclude from night differential
            if earliest == latest:
                df.at[index, "Ord-ND"] = 0
                #print(f"No day calculation: Earliest = {earliest}, Latest = {latest}")
                continue

            # Calculate Night Differential based on the conditions
            # earliest < night end check if the employee logs in in the early morning
            # earliest >= night_start check if the logs in the night
            if earliest < night_end or earliest >= night_start:

                # Different Day
                if earliest > latest:
                    # print(
                    #     f"Different day calculation: Earliest = {earliest}, Latest = {latest}"
                    # )
                    df.at[index, "Ord-ND"] = (
                        (df.at[index, "Latest Time"] + pd.Timedelta(hours=24))
                        - earliest
                    ).total_seconds() / 3600.0

                # Same day
                elif earliest < latest:
                    # print(
                    #     f"Same day calculation: Earliest = {earliest}, Latest = {latest}"
                    # )

                    # Only compute until only 6am
                    if latest >= night_end:
                        df.at[index, "Ord-ND"] = (
                            night_end - earliest
                        ).total_seconds() / 3600.0
                        # print(
                        #     f"Same day 1 calculation: Earliest = {earliest}, Latest = {latest}"
                        # )

                    else:
                        df.at[index, "Ord-ND"] = (
                            latest - earliest
                        ).total_seconds() / 3600.0
                        # print(
                        #     f"Same day 2 calculation: Earliest = {earliest}, Latest = {latest}"
                        # )

                # if (earliest < latest) or (
                #     earliest >= night_start and latest < night_end
                # ):
                #     print(
                #         f"Same day calculation: Earliest = {earliest}, Latest = {latest}"
                #     )
                #     # Same-day calculation within the night period
                #     df.at[index, "Ord-ND"] = (
                #         latest - earliest
                #     ).total_seconds() / 3600.0
                # else:
                #     print(
                #         f"Different day calculation: Earliest = {earliest}, Latest = {latest}"
                #     )

                # # Same day
                # if latest <= night_end and not (latest < earliest):
                #     # Debug: Same-day calculation
                #     print(
                #         f"Same day calculation: Earliest = {earliest}, Latest = {latest}"
                #     )
                #     # Same-day calculation within the night period
                #     df.at[index, "Ord-ND"] = (
                #         latest - earliest
                #     ).total_seconds() / 3600.0

                # # Next day calculations
                # elif latest > night_end:
                #     # Check if `latest` is earlier than `earliest`, meaning it falls on the next day
                #     if latest < earliest:
                #         # Debug: Next day calculation (crosses midnight)
                #         print(
                #             f"Next day calculation (crosses midnight): Earliest = {earliest}, Latest = {latest}"
                #         )
                #         # Calculate for next day by adding 24 hours to `latest`
                #         valid_latest_time = latest + pd.Timedelta(hours=24)
                #         df.at[index, "Ord-ND"] = (
                #             valid_latest_time - earliest
                #         ).total_seconds() / 3600.0

                #     # Check if earliest is before 6 AM on the next day
                #     elif earliest < pd.to_timedelta("06:00:00"):
                #         # Debug: Next day calculation (up to 6 AM)
                #         print(
                #             f"Next day calculation (up to 6 AM): Earliest = {earliest}, Latest = {latest}"
                #         )
                #         valid_latest_time = pd.to_timedelta("06:00:00")
                #         df.at[index, "Ord-ND"] = (
                #             valid_latest_time - earliest
                #         ).total_seconds() / 3600.0

                #     # If earliest is already after 6 AM, set Ord-ND to 0
                #     else:
                #         # Debug: Next day, earliest after 6 AM
                #         print(
                #             f"Next day, earliest after 6 AM: Earliest = {earliest}, Latest = {latest}"
                #         )
                #         df.at[index, "Ord-ND"] = 0

            else:
                # If it doesn't qualify for night differential, set it to 0
                # print(
                #     f"No night differential: Earliest = {earliest}, Latest = {latest}"
                # )
                df.at[index, "Ord-ND"] = 0

        # Print the calculated values for verification
        #print("Calculated hours worked, RD hours, and Night Differential:")
        #print(df[["Record Date", "Hours Worked", "Ord-OT", "RD", "Ord-ND"]])

        return df
    except Exception as ex:
        print(f"Error calculating hours worked: {ex}")
        # return df  # Return the original DataFrame in case of error


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
                Ord_ND=("Ord-ND", "sum"),
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

        # Convert 'Ord_OT' to 'HH:MM' format
        df_grouped["Ord_OT"] = df_grouped["Ord_OT"].apply(
            lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        )

        # Convert 'RD' to 'HH:MM' format
        df_grouped["RD"] = df_grouped["RD"].apply(
            lambda x: f"{int(x)}:{int((x - int(x)) * 60):02d}"
        )

        # Convert 'Night' to 'HH:MM' format
        df_grouped["Ord_ND"] = df_grouped["Ord_ND"].apply(
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
    """Prepares the final DataFrame for Excel output."""
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
            "Ord-ND-OT",
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

        for header in headers:
            if header not in df_grouped.columns:
                df_grouped[header] = None

        df_grouped = df_grouped.reindex(columns=headers)
        df_grouped.to_excel(output_excel_file, index=False)

        wb = load_workbook(output_excel_file)
        ws = wb.active

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

        wb.save(output_excel_file)
    except Exception as ex:
        print(f"Error preparing Excel output: {ex}")


def main(input_csv_file):
    """Main function to orchestrate the employee data processing."""
    try:
        output_excel_file = "output3.xlsx"
        data_csv_file = "BiometricAttendanceInfo.csv"

        # Reading and processing CSV files
        df, data = read_csv_files(input_csv_file, data_csv_file)
        if df is None or data is None:
            print("Failed to read CSV files.")
            return

        # Preprocessing names, merging data, calculating hours, etc.
        df, data = preprocess_names(df, data)
        df = merge_dataframes(df, data)
        df = calculate_hours_worked(df)
        df_grouped = group_employee_data(df)

        # Preparing the output Excel file
        prepare_excel(df_grouped, output_excel_file)
        # print(df_grouped)

    except Exception as ex:
        print(f"Error in main: {ex}")


# Argument parser setup
parser = argparse.ArgumentParser(description="Process employee attendance data.")
parser.add_argument("input_csv_file", type=str, help="The path to the input CSV file")

# Parse arguments and call main
args = parser.parse_args()
main(args.input_csv_file)
