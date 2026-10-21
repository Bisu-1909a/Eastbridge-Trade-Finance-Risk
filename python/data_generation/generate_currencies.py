import csv
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "currencies.csv"


CURRENCIES = [
    (1, "USD", "US Dollar"),
    (2, "EUR", "Euro"),
    (3, "GBP", "British Pound"),
    (4, "INR", "Indian Rupee"),
    (5, "CNY", "Chinese Yuan"),
    (6, "JPY", "Japanese Yen"),
    (7, "SGD", "Singapore Dollar"),
    (8, "AED", "United Arab Emirates Dirham"),
    (9, "AUD", "Australian Dollar"),
    (10, "CAD", "Canadian Dollar"),
]


def generate_currencies():
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)

        writer.writerow([
            "currency_id",
            "currency_code",
            "currency_name"
        ])

        writer.writerows(CURRENCIES)

    print("Currencies generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(CURRENCIES)}")


if __name__ == "__main__":
    generate_currencies()
