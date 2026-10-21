import csv
import random
from datetime import date, timedelta
from pathlib import Path


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "trades.csv"


# ============================================================
# Configuration
# ============================================================

NUMBER_OF_TRADES = 100

START_DATE = date(2026, 1, 1)

RANDOM_SEED = 42


# ============================================================
# Trade generation
# ============================================================

def generate_trades():

    random.seed(RANDOM_SEED)

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    rows = []

    for trade_id in range(1, NUMBER_OF_TRADES + 1):

        customer_id = random.randint(1, 10)

        supplier_id = random.randint(1, 10)

        product_id = random.randint(1, 10)

        route_id = random.randint(1, 10)

        currency_id = random.randint(1, 10)

        trade_date = START_DATE + timedelta(
            days=random.randint(0, 180)
        )

        trade_status = random.choice([
            "ACTIVE",
            "COMPLETED",
            "IN_TRANSIT",
            "PENDING"
        ])

        # ----------------------------------------------------
        # Financial values
        # ----------------------------------------------------

        expected_revenue = round(
            random.uniform(10000, 100000),
            2
        )

        procurement_ratio = random.uniform(
            0.55,
            0.80
        )

        expected_procurement_cost = round(
            expected_revenue * procurement_ratio,
            2
        )

        operational_ratio = random.uniform(
            0.05,
            0.15
        )

        expected_operational_cost = round(
            expected_revenue * operational_ratio,
            2
        )

        # ----------------------------------------------------
        # Expected dates
        # ----------------------------------------------------

        expected_shipment_date = (
            trade_date + timedelta(
                days=random.randint(7, 30)
            )
        )

        expected_payment_date = (
            trade_date + timedelta(
                days=random.randint(30, 90)
            )
        )

        # ----------------------------------------------------
        # Store row
        # ----------------------------------------------------

        rows.append([
            trade_id,
            customer_id,
            supplier_id,
            product_id,
            route_id,
            currency_id,
            trade_date.isoformat(),
            trade_status,
            expected_revenue,
            expected_procurement_cost,
            expected_operational_cost,
            expected_shipment_date.isoformat(),
            expected_payment_date.isoformat()
        ])

    # ========================================================
    # Write CSV
    # ========================================================

    with open(
        OUTPUT_FILE,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:

        writer = csv.writer(file)

        writer.writerow([
            "trade_id",
            "customer_id",
            "supplier_id",
            "product_id",
            "route_id",
            "currency_id",
            "trade_date",
            "trade_status",
            "expected_revenue",
            "expected_procurement_cost",
            "expected_operational_cost",
            "expected_shipment_date",
            "expected_payment_date"
        ])

        writer.writerows(rows)

    print("Trades generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(rows)}")


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    generate_trades()
    