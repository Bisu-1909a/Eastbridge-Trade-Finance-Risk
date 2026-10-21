import csv
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "products.csv"


PRODUCTS = [
    (1, "Industrial Machinery", "Machinery"),
    (2, "Electronic Components", "Electronics"),
    (3, "Automotive Parts", "Automotive"),
    (4, "Pharmaceutical Equipment", "Healthcare"),
    (5, "Solar Equipment", "Energy"),
    (6, "Textile Materials", "Textiles"),
    (7, "Food Processing Equipment", "Food & Beverage"),
    (8, "Construction Materials", "Construction"),
    (9, "Consumer Electronics", "Electronics"),
    (10, "Chemical Raw Materials", "Chemicals"),
]


def generate_products():
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)

        writer.writerow([
            "product_id",
            "product_name",
            "product_category"
        ])

        writer.writerows(PRODUCTS)

    print("Products generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(PRODUCTS)}")


if __name__ == "__main__":
    generate_products()
