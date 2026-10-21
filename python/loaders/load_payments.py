import csv
import sqlite3

DB_PATH = "database/eastbridge.db"
CSV_PATH = "data/raw/payments.csv"


def main():
    print("Loading EastBridge payment data...")

    with open(CSV_PATH, newline="", encoding="utf-8") as file:
        rows = list(csv.DictReader(file))

    print(f"Found {len(rows)} payment records.")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.executemany(
        """
        INSERT INTO payment (
            payment_id,
            invoice_id,
            payment_date,
            payment_amount,
            currency_id,
            payment_method,
            payment_status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        [
            (
                int(row["payment_id"]),
                int(row["invoice_id"]),
                row["payment_date"],
                float(row["payment_amount"]),
                int(row["currency_id"]),
                row["payment_method"],
                row["payment_status"],
            )
            for row in rows
        ],
    )

    conn.commit()
    conn.close()

    print(f"Payments loaded successfully: {len(rows)}")


if __name__ == "__main__":
    main()