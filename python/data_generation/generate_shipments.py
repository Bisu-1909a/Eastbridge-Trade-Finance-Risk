import csv
import random
from datetime import date, timedelta
from pathlib import Path


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

TRADES_FILE = PROJECT_ROOT / "data" / "raw" / "trades.csv"
OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "shipments.csv"


# ============================================================
# Configuration
# ============================================================

RANDOM_SEED = 42


# ============================================================
# Read trades
# ============================================================

def read_trades():
    with open(
        TRADES_FILE,
        "r",
        encoding="utf-8"
    ) as file:
        return list(csv.DictReader(file))


# ============================================================
# Generate shipments
# ============================================================

def generate_shipments():

    random.seed(RANDOM_SEED)

    trades = read_trades()

    rows = []

    shipment_id = 1

    for trade in trades:

        trade_id = int(trade["trade_id"])

        trade_date = date.fromisoformat(
            trade["trade_date"]
        )

        shipment_date = date.fromisoformat(
            trade["expected_shipment_date"]
        )

        # ----------------------------------------------------
        # Generate expected arrival date
        # ----------------------------------------------------

        expected_transit_days = random.randint(7, 25)

        expected_arrival_date = (
            shipment_date
            + timedelta(days=expected_transit_days)
        )

        # ----------------------------------------------------
        # Determine shipment scenario
        # ----------------------------------------------------

        scenario = random.choices(
            [
                "ON_TIME",
                "DELAYED",
                "IN_TRANSIT"
            ],
            weights=[
                55,
                30,
                15
            ],
            k=1
        )[0]

        # ----------------------------------------------------
        # Delivered on time
        # ----------------------------------------------------

        if scenario == "ON_TIME":

            actual_arrival_date = expected_arrival_date

            shipment_status = "DELIVERED"

        # ----------------------------------------------------
        # Delivered late
        # ----------------------------------------------------

        elif scenario == "DELAYED":

            delay_days = random.randint(3, 20)

            actual_arrival_date = (
                expected_arrival_date
                + timedelta(days=delay_days)
            )

            shipment_status = "DELAYED"

        # ----------------------------------------------------
        # Still in transit
        # ----------------------------------------------------

        else:

            actual_arrival_date = None

            shipment_status = "IN_TRANSIT"

        # ----------------------------------------------------
        # Validation checks
        # ----------------------------------------------------

        assert expected_arrival_date >= shipment_date

        if actual_arrival_date:

            assert actual_arrival_date >= shipment_date

            assert actual_arrival_date >= trade_date

        # ----------------------------------------------------
        # Add shipment
        # ----------------------------------------------------

        rows.append([
            shipment_id,
            trade_id,
            shipment_date.isoformat(),
            expected_arrival_date.isoformat(),
            (
                actual_arrival_date.isoformat()
                if actual_arrival_date
                else ""
            ),
            shipment_status
        ])

        shipment_id += 1

    # ========================================================
    # Write CSV
    # ========================================================

    OUTPUT_FILE.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    with open(
        OUTPUT_FILE,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:

        writer = csv.writer(file)

        writer.writerow([
            "shipment_id",
            "trade_id",
            "shipment_date",
            "expected_arrival_date",
            "actual_arrival_date",
            "shipment_status"
        ])

        writer.writerows(rows)

    print("Shipments generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(rows)}")


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    generate_shipments()
    