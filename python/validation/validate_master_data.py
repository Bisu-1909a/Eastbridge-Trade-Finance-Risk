import csv
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA = PROJECT_ROOT / "data" / "raw"


def read_csv(filename):
    file_path = RAW_DATA / filename

    with open(file_path, "r", encoding="utf-8") as file:
        return list(csv.DictReader(file))


def validate_unique_ids(rows, column, dataset):
    ids = [row[column] for row in rows]

    if len(ids) != len(set(ids)):
        raise ValueError(f"Duplicate {column} found in {dataset}.")

    print(f"✓ {dataset}: IDs are unique.")


def validate_country_references(rows, dataset, column="country_id"):
    countries = read_csv("countries.csv")
    valid_ids = {row["country_id"] for row in countries}

    for row in rows:
        if row[column] not in valid_ids:
            raise ValueError(
                f"Invalid country_id {row[column]} in {dataset}."
            )

    print(f"✓ {dataset}: country references are valid.")


def validate_routes(rows):
    countries = read_csv("countries.csv")
    valid_ids = {row["country_id"] for row in countries}

    for row in rows:
        if row["origin_country_id"] not in valid_ids:
            raise ValueError(
                f"Invalid origin_country_id in routes: {row['origin_country_id']}"
            )

        if row["destination_country_id"] not in valid_ids:
            raise ValueError(
                f"Invalid destination_country_id in routes: "
                f"{row['destination_country_id']}"
            )

    print("✓ routes: country references are valid.")


def validate_master_data():
    print("Validating EastBridge master data...\n")

    countries = read_csv("countries.csv")
    currencies = read_csv("currencies.csv")
    customers = read_csv("customers.csv")
    suppliers = read_csv("suppliers.csv")
    products = read_csv("products.csv")
    routes = read_csv("routes.csv")

    validate_unique_ids(countries, "country_id", "countries")
    validate_unique_ids(currencies, "currency_id", "currencies")
    validate_unique_ids(customers, "customer_id", "customers")
    validate_unique_ids(suppliers, "supplier_id", "suppliers")
    validate_unique_ids(products, "product_id", "products")
    validate_unique_ids(routes, "route_id", "routes")

    validate_country_references(customers, "customers")
    validate_country_references(suppliers, "suppliers")
    validate_routes(routes)

    print("\nMaster data validation passed.")
    print(f"Countries: {len(countries)}")
    print(f"Currencies: {len(currencies)}")
    print(f"Customers: {len(customers)}")
    print(f"Suppliers: {len(suppliers)}")
    print(f"Products: {len(products)}")
    print(f"Routes: {len(routes)}")


if __name__ == "__main__":
    validate_master_data()
    