import sqlite3
from pathlib import Path


# Project root
PROJECT_ROOT = Path(__file__).resolve().parents[1]

# File paths
SCHEMA_FILE = PROJECT_ROOT / "sql" / "schema" / "schema.sql"
DATABASE_FILE = PROJECT_ROOT / "database" / "eastbridge.db"


def create_database():
    print("Creating EastBridge database...")

    # Read schema
    schema = SCHEMA_FILE.read_text(encoding="utf-8")

    # Create database connection
    connection = sqlite3.connect(DATABASE_FILE)

    try:
        # Enable foreign keys
        connection.execute("PRAGMA foreign_keys = ON")

        # Create all tables
        connection.executescript(schema)

        # Save changes
        connection.commit()

        print("Database created successfully.")
        print(f"Location: {DATABASE_FILE}")

    except sqlite3.Error as error:
        connection.rollback()
        print("Database creation failed.")
        print(error)

    finally:
        connection.close()


if __name__ == "__main__":
    create_database()
    