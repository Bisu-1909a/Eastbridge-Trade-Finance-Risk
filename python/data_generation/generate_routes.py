import csv
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "routes.csv"


ROUTES = [
    (1, 1, 2, "India to United States"),
    (2, 1, 3, "India to United Kingdom"),
    (3, 1, 4, "India to Germany"),
    (4, 5, 1, "China to India"),
    (5, 5, 2, "China to United States"),
    (6, 6, 1, "Japan to India"),
    (7, 7, 1, "Singapore to India"),
    (8, 8, 1, "United Arab Emirates to India"),
    (9, 9, 3, "Netherlands to United Kingdom"),
    (10, 10, 2, "Australia to United States"),
]


def generate_routes():
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)

        writer.writerow([
            "route_id",
            "origin_country_id",
            "destination_country_id",
            "route_name"
        ])

        writer.writerows(ROUTES)

    print("Routes generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(ROUTES)}")


if __name__ == "__main__":
    generate_routes()
    