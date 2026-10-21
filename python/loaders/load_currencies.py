import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_PATH = BASE_DIR / "database" / "eastbridge.db"
CURRENCIES_FILE = BASE_DIR / "data" / "raw" / "currencies.csv"


def main():
    print("Loading EastBridge currency data...")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    with open(CURRENCIES_FILE, "r", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        rows = list(reader)

    print(f"Found {len(rows)} currency records.")

    cursor.executemany(
        """
        INSERT INTO currency (
            currency_id,
            currency_code,
            currency_name
        )
        VALUES (?, ?, ?)
        """,
        [
            (
                int(row["currency_id"]),
                row["currency_code"],
                row["currency_name"],
            )
            for row in rows
        ],
    )

    conn.commit()

    count = cursor.execute(
        "SELECT COUNT(*) FROM currency"
    ).fetchone()[0]

    conn.close()

    print(f"Currencies loaded successfully: {count}")


if __name__ == "__main__":
    main()