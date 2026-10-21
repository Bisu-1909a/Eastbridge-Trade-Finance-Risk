import csv
import sqlite3

DB_PATH = "database/eastbridge.db"
CSV_PATH = "data/raw/shipments.csv"


def main():
    print("Loading EastBridge shipment data...")

    with open(CSV_PATH, newline="", encoding="utf-8") as file:
        rows = list(csv.DictReader(file))

    print(f"Found {len(rows)} shipment records.")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.executemany(
        """
        INSERT INTO shipment (
            shipment_id,
            trade_id,
            shipment_date,
            expected_arrival_date,
            actual_arrival_date,
            shipment_status
        )
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        [
            (
                int(row["shipment_id"]),
                int(row["trade_id"]),
                row["shipment_date"],
                row["expected_arrival_date"],
                row["actual_arrival_date"] or None,
                row["shipment_status"],
            )
            for row in rows
        ],
    )

    conn.commit()
    conn.close()

    print(f"Shipments loaded successfully: {len(rows)}")


if __name__ == "__main__":
    main()