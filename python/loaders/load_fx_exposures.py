import csv
import sqlite3

DB_PATH = "database/eastbridge.db"
CSV_PATH = "data/raw/fx_exposures.csv"


def main():
    print("Loading EastBridge FX exposure data...")

    with open(CSV_PATH, newline="", encoding="utf-8") as file:
        rows = list(csv.DictReader(file))

    print(f"Found {len(rows)} FX exposure records.")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.executemany(
        """
        INSERT INTO fx_exposure (
            fx_exposure_id,
            trade_id,
            currency_id,
            exposure_direction,
            exposure_amount,
            exposure_start_date,
            expected_settlement_date
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        [
            (
                int(row["fx_exposure_id"]),
                int(row["trade_id"]),
                int(row["currency_id"]),
                "RECEIVABLE",
                float(row["exposure_amount"]),
                row["exposure_date"],
                row["maturity_date"],
            )
            for row in rows
        ],
    )

    conn.commit()
    conn.close()

    print(f"FX exposures loaded successfully: {len(rows)}")


if __name__ == "__main__":
    main()