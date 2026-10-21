import sqlite3
from pathlib import Path


# Project root
PROJECT_ROOT = Path(__file__).resolve().parents[2]

# Schema file
SCHEMA_FILE = PROJECT_ROOT / "sql" / "schema" / "schema.sql"


def validate_schema():
    print("Loading schema...")

    schema = SCHEMA_FILE.read_text(encoding="utf-8")

    connection = sqlite3.connect(":memory:")

    try:
        connection.executescript(schema)

        print("Schema executed successfully.")

        cursor = connection.cursor()

        cursor.execute("""
            SELECT name
            FROM sqlite_master
            WHERE type = 'table'
            ORDER BY name;
        """)

        tables = cursor.fetchall()

        print("\nTables created:")
        for table in tables:
            print(f"- {table[0]}")

        print(f"\nTotal tables: {len(tables)}")

    except sqlite3.Error as error:
        print("\nSchema validation failed.")
        print(error)

    finally:
        connection.close()


if __name__ == "__main__":
    validate_schema()
