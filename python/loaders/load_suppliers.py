import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_PATH = BASE_DIR / "database" / "eastbridge.db"
SUPPLIERS_FILE = BASE_DIR / "data" / "raw" / "suppliers.csv"


def main():
    print("Loading EastBridge supplier data...")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    with open(SUPPLIERS_FILE, "r", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        rows = list(reader)

    print(f"Found {len(rows)} supplier records.")

    cursor.executemany(
        """
        INSERT INTO supplier (
            supplier_id,
            supplier_name,
            country_id,
            supplier_type
        )
        VALUES (?, ?, ?, ?)
        """,
        [
            (
                int(row["supplier_id"]),
                row["supplier_name"],
                int(row["country_id"]),
                row["supplier_type"],
            )
            for row in rows
        ],
    )

    conn.commit()

    count = cursor.execute(
        "SELECT COUNT(*) FROM supplier"
    ).fetchone()[0]

    conn.close()

    print(f"Suppliers loaded successfully: {count}")


if __name__ == "__main__":
    main()