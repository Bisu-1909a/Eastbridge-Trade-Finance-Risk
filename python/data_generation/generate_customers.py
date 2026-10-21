import csv
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "customers.csv"


CUSTOMERS = [
    (1, "Global Retail Corp", 2, "Retail", "Enterprise"),
    (2, "EuroTech Industries", 4, "Technology", "Enterprise"),
    (3, "IndoMart Trading", 1, "Retail", "Mid-Market"),
    (4, "Pacific Electronics", 6, "Electronics", "Enterprise"),
    (5, "Gulf Distribution LLC", 8, "Distribution", "Enterprise"),
    (6, "London Machinery Ltd", 3, "Manufacturing", "Mid-Market"),
    (7, "Singapore Supply Co", 7, "Logistics", "Enterprise"),
    (8, "Aussie Home Goods", 10, "Consumer Goods", "Mid-Market"),
    (9, "Dutch Import Partners", 9, "Import", "Enterprise"),
    (10, "Asia Commerce Group", 5, "Trading", "Enterprise"),
]


def generate_customers():
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)

        writer.writerow([
            "customer_id",
            "customer_name",
            "country_id",
            "industry",
            "customer_segment"
        ])

        writer.writerows(CUSTOMERS)

    print("Customers generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(CUSTOMERS)}")


if __name__ == "__main__":
    generate_customers()
    