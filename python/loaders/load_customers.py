import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_PATH = BASE_DIR / "database" / "eastbridge.db"
CUSTOMERS_FILE = BASE_DIR / "data" / "raw" / "customers.csv"


def main():
    print("Loading EastBridge customer data...")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    with open(CUSTOMERS_FILE, "r", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        rows = list(reader)

    print(f"Found {len(rows)} customer records.")

    cursor.executemany(
        """
        INSERT INTO customer (
            customer_id,
            customer_name,
            country_id,
            industry,
            customer_segment
        )
        VALUES (?, ?, ?, ?, ?)
        """,
        [
            (
                int(row["customer_id"]),
                row["customer_name"],
                int(row["country_id"]),
                row["industry"],
                row["customer_segment"],
            )
            for row in rows
        ],
    )

    conn.commit()

    count = cursor.execute(
        "SELECT COUNT(*) FROM customer"
    ).fetchone()[0]

    conn.close()

    print(f"Customers loaded successfully: {count}")


if __name__ == "__main__":
    main()