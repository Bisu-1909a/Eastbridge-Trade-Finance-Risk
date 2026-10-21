import csv
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA = PROJECT_ROOT / "data" / "raw"


def read_csv(filename):
    file_path = RAW_DATA / filename

    with open(file_path, "r", encoding="utf-8") as file:
        return list(csv.DictReader(file))


def validate_reference_ids(trades, filename, trade_column, reference_column):
    reference_rows = read_csv(filename)

    valid_ids = {
        row[reference_column]
        for row in reference_rows
    }

    for trade in trades:
        if trade[trade_column] not in valid_ids:
            raise ValueError(
                f"Invalid {trade_column} "
                f"{trade[trade_column]} in trade "
                f"{trade['trade_id']}."
            )

    print(
        f"✓ trades → {filename.replace('.csv', '')} "
        "references are valid."
    )


def validate_unique_trade_ids(trades):
    trade_ids = [trade["trade_id"] for trade in trades]

    if len(trade_ids) != len(set(trade_ids)):
        raise ValueError("Duplicate trade_id found.")

    print("✓ trade IDs are unique.")


def validate_dates(trades):
    for trade in trades:
        if trade["expected_shipment_date"] < trade["trade_date"]:
            raise ValueError(
                f"Shipment date is before trade date "
                f"for trade {trade['trade_id']}."
            )

        if trade["expected_payment_date"] < trade["trade_date"]:
            raise ValueError(
                f"Payment date is before trade date "
                f"for trade {trade['trade_id']}."
            )

    print("✓ Trade dates are valid.")


def validate_financial_values(trades):
    for trade in trades:
        revenue = float(trade["expected_revenue"])
        procurement = float(
            trade["expected_procurement_cost"]
        )
        operational = float(
            trade["expected_operational_cost"]
        )

        if revenue <= 0:
            raise ValueError(
                f"Invalid revenue for trade {trade['trade_id']}."
            )

        if procurement <= 0:
            raise ValueError(
                f"Invalid procurement cost for trade "
                f"{trade['trade_id']}."
            )

        if operational < 0:
            raise ValueError(
                f"Invalid operational cost for trade "
                f"{trade['trade_id']}."
            )

    print("✓ Financial values are valid.")


def validate_trade_status(trades):
    valid_statuses = {
        "ACTIVE",
        "COMPLETED",
        "IN_TRANSIT",
        "PENDING"
    }

    for trade in trades:
        if trade["trade_status"] not in valid_statuses:
            raise ValueError(
                f"Invalid trade status "
                f"{trade['trade_status']} "
                f"for trade {trade['trade_id']}."
            )

    print("✓ Trade statuses are valid.")


def validate_trades():
    print("Validating EastBridge trade data...\n")

    trades = read_csv("trades.csv")

    if len(trades) != 100:
        raise ValueError(
            f"Expected 100 trades, found {len(trades)}."
        )

    print("✓ Trade count is 100.")

    validate_unique_trade_ids(trades)

    validate_reference_ids(
        trades,
        "customers.csv",
        "customer_id",
        "customer_id"
    )

    validate_reference_ids(
        trades,
        "suppliers.csv",
        "supplier_id",
        "supplier_id"
    )

    validate_reference_ids(
        trades,
        "products.csv",
        "product_id",
        "product_id"
    )

    validate_reference_ids(
        trades,
        "routes.csv",
        "route_id",
        "route_id"
    )

    validate_reference_ids(
        trades,
        "currencies.csv",
        "currency_id",
        "currency_id"
    )

    validate_dates(trades)

    validate_financial_values(trades)

    validate_trade_status(trades)

    print("\nTrade data validation passed.")


if __name__ == "__main__":
    validate_trades()
