import csv
from pathlib import Path


# Project root
PROJECT_ROOT = Path(__file__).resolve().parents[2]

# Output file
OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "countries.csv"


COUNTRIES = [
    (1, "IN", "India"),
    (2, "US", "United States"),
    (3, "GB", "United Kingdom"),
    (4, "DE", "Germany"),
    (5, "CN", "China"),
    (6, "JP", "Japan"),
    (7, "SG", "Singapore"),
    (8, "AE", "United Arab Emirates"),
    (9, "NL", "Netherlands"),
    (10, "AU", "Australia"),
]


def generate_countries():
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)

        writer.writerow([
            "country_id",
            "country_code",
            "country_name"
        ])

        writer.writerows(COUNTRIES)

    print("Countries generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(COUNTRIES)}")


if __name__ == "__main__":
    generate_countries()
