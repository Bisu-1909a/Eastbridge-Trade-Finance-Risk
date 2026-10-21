import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_PATH = BASE_DIR / "database" / "eastbridge.db"
EVENTS_FILE = BASE_DIR / "data" / "raw" / "operational_events.csv"


def main():
    print("Loading EastBridge operational event data...")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    with open(EVENTS_FILE, "r", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        rows = list(reader)

    print(f"Found {len(rows)} operational event records.")

    cursor.executemany(
        """
        INSERT INTO operational_event (
            operational_event_id,
            shipment_id,
            event_type,
            event_date,
            event_description
        )
        VALUES (?, ?, ?, ?, ?)
        """,
        [
            (
                int(row["operational_event_id"]),
                int(row["shipment_id"]),
                row["event_type"],
                row["event_date"],
                row["event_description"],
            )
            for row in rows
        ],
    )

    conn.commit()

    count = cursor.execute(
        "SELECT COUNT(*) FROM operational_event"
    ).fetchone()[0]

    conn.close()

    print(f"Operational events loaded successfully: {count}")


if __name__ == "__main__":
    main()