import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_PATH = BASE_DIR / "database" / "eastbridge.db"
ROUTES_FILE = BASE_DIR / "data" / "raw" / "routes.csv"


def main():
    print("Loading EastBridge route data...")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    with open(ROUTES_FILE, "r", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        rows = list(reader)

    print(f"Found {len(rows)} route records.")

    cursor.executemany(
        """
        INSERT INTO route (
            route_id,
            origin_country_id,
            destination_country_id,
            route_name
        )
        VALUES (?, ?, ?, ?)
        """,
        [
            (
                int(row["route_id"]),
                int(row["origin_country_id"]),
                int(row["destination_country_id"]),
                row["route_name"],
            )
            for row in rows
        ],
    )

    conn.commit()

    count = cursor.execute(
        "SELECT COUNT(*) FROM route"
    ).fetchone()[0]

    conn.close()

    print(f"Routes loaded successfully: {count}")


if __name__ == "__main__":
    main()