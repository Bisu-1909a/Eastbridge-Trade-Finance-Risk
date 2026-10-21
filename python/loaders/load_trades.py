import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_PATH = BASE_DIR / "database" / "eastbridge.db"
TRADES_FILE = BASE_DIR / "data" / "raw" / "trades.csv"


def main():
    print("Loading EastBridge trade data...")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    with open(TRADES_FILE, "r", encoding="utf-8") as file:
        reader = csv.DictReader(file)

        rows = list(reader)

    print(f"Found {len(rows)} trade records.")

    cursor.executemany(
        """
        INSERT INTO trade (
            trade_id,
            customer_id,
            supplier_id,
            product_id,
            route_id,
            currency_id,
            trade_date,
            trade_status,
            expected_revenue,
            expected_procurement_cost,
            expected_operational_cost,
            expected_shipment_date,
            expected_payment_date
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        [
            (
                int(row["trade_id"]),
                int(row["customer_id"]),
                int(row["supplier_id"]),
                int(row["product_id"]),
                int(row["route_id"]),
                int(row["currency_id"]),
                row["trade_date"],
                row["trade_status"],
                float(row["expected_revenue"]),
                float(row["expected_procurement_cost"]),
                float(row["expected_operational_cost"]),
                row["expected_shipment_date"],
                row["expected_payment_date"],
            )
            for row in rows
        ],
    )

    conn.commit()

    count = cursor.execute(
        "SELECT COUNT(*) FROM trade"
    ).fetchone()[0]

    conn.close()

    print(f"Trades loaded successfully: {count}")


if __name__ == "__main__":
    main()
