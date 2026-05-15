"""
Load raw Excel data into DuckDB as bronze tables.

Reads data/raw/2026-04-21_elist_data_cleaned.xlsx and writes its two
sheets to the dbt project's DuckDB file as bronze.orders_raw and
bronze.country_lookup_raw. Run this once before `dbt build`.

Bronze design principle: preserve the source faithfully, including
inconsistent formats. All columns load as VARCHAR. Type casting and
cleaning happen in the silver layer (stg_orders, stg_country_lookup).

Usage:
    python scripts/load_bronze.py
"""
from pathlib import Path
import duckdb
import pandas as pd

REPO_ROOT = Path(__file__).resolve().parents[1]
EXCEL_PATH = REPO_ROOT / "data" / "raw" / "2026-04-21_elist_data_cleaned.xlsx"
DUCKDB_PATH = REPO_ROOT / "dbt" / "dev.duckdb"


def main() -> None:
    print(f"Reading Excel: {EXCEL_PATH}")
    # dtype=str forces every column to load as string, preserving raw values
    # exactly as written without pandas/DuckDB inferring types.
    orders = pd.read_excel(EXCEL_PATH, sheet_name="orders_data_cleaned", dtype=str)
    countries = pd.read_excel(EXCEL_PATH, sheet_name="country_lookup_raw", dtype=str)
    print(f"  orders_data_cleaned:  {len(orders):,} rows, {len(orders.columns)} cols")
    print(f"  country_lookup_raw:   {len(countries):,} rows, {len(countries.columns)} cols")

    print(f"\nWriting to DuckDB: {DUCKDB_PATH}")
    con = duckdb.connect(str(DUCKDB_PATH))
    con.execute("CREATE SCHEMA IF NOT EXISTS bronze")
    con.execute("CREATE OR REPLACE TABLE bronze.orders_raw AS SELECT * FROM orders")
    con.execute("CREATE OR REPLACE TABLE bronze.country_lookup_raw AS SELECT * FROM countries")

    orders_count = con.execute("SELECT COUNT(*) FROM bronze.orders_raw").fetchone()[0]
    countries_count = con.execute("SELECT COUNT(*) FROM bronze.country_lookup_raw").fetchone()[0]
    print(f"  bronze.orders_raw:           {orders_count:,} rows")
    print(f"  bronze.country_lookup_raw:   {countries_count:,} rows")
    con.close()
    print("\nDone.")


if __name__ == "__main__":
    main()
