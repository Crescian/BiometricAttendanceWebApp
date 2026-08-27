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

        # Calculate hours worked, handling non-finite values
        df["Hours Worked"] = (
            df["Latest Time"] - df["Earliest Time"]
        ).dt.total_seconds() / 3600.0

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
        print(non_working_days)
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

        # Calculate Night Differential (time worked between 10 PM and 6 AM)
        night_start = pd.to_timedelta("22:00:00")
        night_end = pd.to_timedelta("06:00:00")

        # Ensure the calculation for Night Differential uses correct time comparisons
        df["Ord-ND"] = (
            (
                (
                    (df["Earliest Time"] >= night_start)
                    | (df["Earliest Time"] < night_end)
                )
                & (df["Latest Time"] <= night_end)
                & (df["Earliest Time"] < df["Latest Time"])
            ).astype(int)
        ) * ((df["Latest Time"] - df["Earliest Time"]).dt.total_seconds() / 3600.0)

        # Print the calculated values for verification
        print("Calculated hours worked, RD hours, and Night Differential:")
        print(df[["Record Date", "Hours Worked", "Ord-OT", "RD", "Ord-ND"]])

        return df

    except Exception as ex:
        print(f"Error calculating hours worked: {ex}")
        return df  # Return the original DataFrame in case of error


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
        print(df_grouped)

    except Exception as ex:
        print(f"Error in main: {ex}")


# Argument parser setup
parser = argparse.ArgumentParser(description="Process employee attendance data.")
parser.add_argument("input_csv_file", type=str, help="The path to the input CSV file")

# Parse arguments and call main
args = parser.parse_args()
main(args.input_csv_file)
