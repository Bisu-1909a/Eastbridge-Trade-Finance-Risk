import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_FILE = BASE_DIR / "database" / "eastbridge.db"
HEDGE_FILE = BASE_DIR / "data" / "raw" / "hedges.csv"


def main():

    print("Loading EastBridge hedge data...")

    with open(HEDGE_FILE, "r", newline="", encoding="utf-8") as file:
        hedges = list(csv.DictReader(file))

    print(f"Found {len(hedges)} hedge records.")

    connection = sqlite3.connect(DB_FILE)
    cursor = connection.cursor()

    cursor.executemany(
        """
        INSERT OR REPLACE INTO hedge (
            hedge_id,
            fx_exposure_id,
            hedge_date,
            hedge_type,
            hedged_amount,
            hedge_rate,
            hedge_status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        [
            (
                int(row["hedge_id"]),
                int(row["fx_exposure_id"]),
                row["hedge_date"],
                row["hedge_type"],
                float(row["hedged_amount"]),
                float(row["hedge_rate"]),
                row["hedge_status"],
            )
            for row in hedges
        ],
    )

    connection.commit()
    connection.close()

    print(f"Hedges loaded successfully: {len(hedges)}")


if __name__ == "__main__":
    main()