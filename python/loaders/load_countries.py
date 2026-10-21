import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_PATH = BASE_DIR / "database" / "eastbridge.db"
COUNTRIES_FILE = BASE_DIR / "data" / "raw" / "countries.csv"


def main():
    print("Loading EastBridge country data...")

    with open(COUNTRIES_FILE, "r", encoding="utf-8", newline="") as file:
        reader = csv.DictReader(file)
        rows = [
            (
                int(row["country_id"]),
                row["country_code"],
                row["country_name"],
            )
            for row in reader
        ]

    print(f"Found {len(rows)} country records.")

    with sqlite3.connect(DB_PATH) as conn:
        conn.executemany(
            """
            INSERT INTO country (
                country_id,
                country_code,
                country_name
            )
            VALUES (?, ?, ?)
            """,
            rows,
        )

        count = conn.execute(
            "SELECT COUNT(*) FROM country"
        ).fetchone()[0]

    print(f"Countries loaded successfully: {count}")


if __name__ == "__main__":
    main()
