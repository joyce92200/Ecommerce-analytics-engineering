"""
Export gold-layer marts (and helper dims) from DuckDB to CSVs for the
Streamlit dashboard. Run after `dbt build` to refresh dashboard data.

Pipeline:
    python scripts/load_bronze.py   # Excel -> DuckDB bronze tables
    cd dbt && dbt build             # bronze -> silver -> gold
    cd .. && python scripts/export_marts.py   # gold -> data/dashboard/*.csv

Usage:
    python scripts/export_marts.py
"""
from pathlib import Path
import duckdb

REPO_ROOT = Path(__file__).resolve().parents[1]
DUCKDB_PATH = REPO_ROOT / "dbt" / "dev.duckdb"
OUTPUT_DIR = REPO_ROOT / "data" / "dashboard"

# (fully-qualified table, output_filename)
# Order matches the dashboard's expectations; one CSV per dashboard input.
EXPORTS = [
    ("gold.mart_cohort_retention",      "mart_cohort_retention.csv"),
    ("gold.mart_loyalty_retention",     "mart_loyalty_retention.csv"),
    ("gold.mart_marketing_acquisition", "mart_marketing_acquisition.csv"),
    ("gold.mart_product_concentration", "mart_product_concentration.csv"),
    ("gold.mart_refund_metrics",        "mart_refund_metrics.csv"),
    ("gold.mart_channel_revenue",       "mart_channel_revenue.csv"),
    ("gold.first_purchase_summary",     "first_purchase_summary.csv"),
    ("gold.dim_country",                "dim_country.csv"),
    ("gold.dim_product",                "dim_product.csv"),
]


def main() -> None:
    print(f"Reading from: {DUCKDB_PATH}")
    print(f"Writing to:   {OUTPUT_DIR}")
    print()

    if not DUCKDB_PATH.exists():
        raise FileNotFoundError(
            f"DuckDB file not found at {DUCKDB_PATH}. "
            "Run `python scripts/load_bronze.py` and `cd dbt && dbt build` first."
        )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    con = duckdb.connect(str(DUCKDB_PATH))
    for table, filename in EXPORTS:
        target = OUTPUT_DIR / filename
        n = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        con.execute(
            f"COPY (SELECT * FROM {table}) TO \'{target.as_posix()}\' "
            f"(HEADER, DELIMITER \',\')"
        )
        print(f"  {filename:42s} {n:>8,} rows")
    con.close()
    print("\nDone.")


if __name__ == "__main__":
    main()
