import sqlite3
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATABASE_FILE = PROJECT_ROOT / "database" / "eastbridge.db"


connection = sqlite3.connect(DATABASE_FILE)
cursor = connection.cursor()

cursor.execute("""
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
    ORDER BY name;
""")

tables = cursor.fetchall()

print("EastBridge Database")
print("-------------------")

for table in tables:
    print(f"✓ {table[0]}")

print(f"\nTotal tables: {len(tables)}")

connection.close()
