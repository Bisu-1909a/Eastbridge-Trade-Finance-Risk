import csv
from datetime import date
from pathlib import Path


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

SHIPMENTS_FILE = PROJECT_ROOT / "data" / "raw" / "shipments.csv"
TRADES_FILE = PROJECT_ROOT / "data" / "raw" / "trades.csv"


# ============================================================
# Configuration
# ============================================================

VALID_STATUSES = {
    "IN_TRANSIT",
    "DELIVERED",
    "DELAYED"
}


# ============================================================
# Helpers
# ============================================================

def read_csv(path):

    with open(
        path,
        "r",
        encoding="utf-8"
    ) as file:

        return list(csv.DictReader(file))


def parse_date(value):

    return date.fromisoformat(value)


# ============================================================
# Main validation
# ============================================================

def validate_shipments():

    print("Validating EastBridge shipment data...\n")

    shipments = read_csv(SHIPMENTS_FILE)
    trades = read_csv(TRADES_FILE)

    # --------------------------------------------------------
    # Shipment count
    # --------------------------------------------------------

    assert len(shipments) == 100

    print("✓ Shipment count is 100.")

    # --------------------------------------------------------
    # Shipment IDs
    # --------------------------------------------------------

    shipment_ids = [
        int(row["shipment_id"])
        for row in shipments
    ]

    assert len(shipment_ids) == len(set(shipment_ids))

    print("✓ Shipment IDs are unique.")

    # --------------------------------------------------------
    # Trade references
    # --------------------------------------------------------

    trade_ids = {
        int(row["trade_id"])
        for row in trades
    }

    shipment_trade_ids = {
        int(row["trade_id"])
        for row in shipments
    }

    assert shipment_trade_ids.issubset(trade_ids)

    print("✓ Shipment → Trade references are valid.")

    # --------------------------------------------------------
    # Every trade has exactly one shipment
    # --------------------------------------------------------

    assert len(shipment_trade_ids) == len(trades)

    trade_reference_count = {}

    for shipment in shipments:

        trade_id = int(shipment["trade_id"])

        trade_reference_count[trade_id] = (
            trade_reference_count.get(trade_id, 0) + 1
        )

    assert all(
        count == 1
        for count in trade_reference_count.values()
    )

    print("✓ Every trade has exactly one shipment.")

    # --------------------------------------------------------
    # Shipment dates
    # --------------------------------------------------------

    for shipment in shipments:

        shipment_date = parse_date(
            shipment["shipment_date"]
        )

        expected_arrival_date = parse_date(
            shipment["expected_arrival_date"]
        )

        assert expected_arrival_date >= shipment_date

        actual_arrival = shipment["actual_arrival_date"]

        if actual_arrival:

            actual_arrival_date = parse_date(
                actual_arrival
            )

            assert actual_arrival_date >= shipment_date

    print("✓ Shipment dates are valid.")

    # --------------------------------------------------------
    # Shipment statuses
    # --------------------------------------------------------

    statuses = {
        row["shipment_status"]
        for row in shipments
    }

    assert statuses.issubset(VALID_STATUSES)

    print("✓ Shipment statuses are valid.")

    # --------------------------------------------------------
    # Delivered shipments must have arrival date
    # --------------------------------------------------------

    for shipment in shipments:

        if shipment["shipment_status"] == "DELIVERED":

            assert shipment["actual_arrival_date"] != ""

    print("✓ Delivered shipments have actual arrival dates.")

    # --------------------------------------------------------
    # In-transit shipments must not have actual arrival date
    # --------------------------------------------------------

    for shipment in shipments:

        if shipment["shipment_status"] == "IN_TRANSIT":

            assert shipment["actual_arrival_date"] == ""

    print("✓ In-transit shipments have no actual arrival date.")

    # --------------------------------------------------------
    # Delayed shipments must have actual arrival date
    # --------------------------------------------------------

    for shipment in shipments:

        if shipment["shipment_status"] == "DELAYED":

            assert shipment["actual_arrival_date"] != ""

            actual_arrival = parse_date(
                shipment["actual_arrival_date"]
            )

            expected_arrival = parse_date(
                shipment["expected_arrival_date"]
            )

            assert actual_arrival > expected_arrival

    print("✓ Delayed shipments have later actual arrival dates.")

    print("\nShipment data validation passed.")


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    validate_shipments()
    