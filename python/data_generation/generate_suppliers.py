import csv
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "suppliers.csv"


SUPPLIERS = [
    (1, "Bharat Components Ltd", 1, "Manufacturer"),
    (2, "Shenzhen Electronics Co", 5, "Manufacturer"),
    (3, "German Industrial Systems", 4, "Manufacturer"),
    (4, "Tokyo Precision Parts", 6, "Manufacturer"),
    (5, "Singapore Logistics Supply", 7, "Distributor"),
    (6, "Dubai Commodity Trading", 8, "Trader"),
    (7, "UK Machinery Suppliers", 3, "Manufacturer"),
    (8, "Dutch Agro Exports", 9, "Exporter"),
    (9, "Australian Raw Materials", 10, "Producer"),
    (10, "US Industrial Supply", 2, "Distributor"),
]


def generate_suppliers():
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)

        writer.writerow([
            "supplier_id",
            "supplier_name",
            "country_id",
            "supplier_type"
        ])

        writer.writerows(SUPPLIERS)

    print("Suppliers generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(SUPPLIERS)}")


if __name__ == "__main__":
    generate_suppliers()
    