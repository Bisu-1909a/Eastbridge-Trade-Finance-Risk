import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_PATH = BASE_DIR / "database" / "eastbridge.db"
PRODUCTS_FILE = BASE_DIR / "data" / "raw" / "products.csv"


def main():
    print("Loading EastBridge product data...")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    with open(PRODUCTS_FILE, "r", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        rows = list(reader)

    print(f"Found {len(rows)} product records.")

    cursor.executemany(
        """
        INSERT INTO product (
            product_id,
            product_name,
            product_category
        )
        VALUES (?, ?, ?)
        """,
        [
            (
                int(row["product_id"]),
                row["product_name"],
                row["product_category"],
            )
            for row in rows
        ],
    )

    conn.commit()

    count = cursor.execute(
        "SELECT COUNT(*) FROM product"
    ).fetchone()[0]

    conn.close()

    print(f"Products loaded successfully: {count}")


if __name__ == "__main__":
    main()