import csv
import random
from datetime import date
from pathlib import Path


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

TRADES_FILE = PROJECT_ROOT / "data" / "raw" / "trades.csv"
OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "fx_exposures.csv"


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
# Generate FX exposures
# ============================================================

def generate_fx_exposures():

    random.seed(RANDOM_SEED)

    trades = read_trades()

    rows = []

    exposure_id = 1

    for trade in trades:

        trade_id = int(trade["trade_id"])

        currency_id = int(trade["currency_id"])

        trade_date = date.fromisoformat(
            trade["trade_date"]
        )

        expected_payment_date = date.fromisoformat(
            trade["expected_payment_date"]
        )

        expected_revenue = float(
            trade["expected_revenue"]
        )

        # ----------------------------------------------------
        # Determine whether trade creates FX exposure
        # ----------------------------------------------------

        # Assume trade currency is the exposure currency.
        #
        # Exposure amount is based on expected revenue.
        #
        # Generate a simple market rate movement scenario.
        # ----------------------------------------------------

        exposure_amount = round(
            expected_revenue,
            2
        )

        spot_rate = round(
            random.uniform(0.75, 1.25),
            4
        )

        forward_rate = round(
            spot_rate * random.uniform(0.97, 1.03),
            4
        )

        # ----------------------------------------------------
        # Calculate potential FX impact
        # ----------------------------------------------------

        potential_fx_loss = round(
            exposure_amount
            * abs(forward_rate - spot_rate)
            / spot_rate,
            2
        )

        # ----------------------------------------------------
        # Risk classification
        # ----------------------------------------------------

        if potential_fx_loss >= 5000:

            risk_level = "HIGH"

        elif potential_fx_loss >= 2000:

            risk_level = "MEDIUM"

        else:

            risk_level = "LOW"

        # ----------------------------------------------------
        # Store exposure
        # ----------------------------------------------------

        rows.append([
            exposure_id,
            trade_id,
            currency_id,
            exposure_amount,
            spot_rate,
            forward_rate,
            potential_fx_loss,
            trade_date.isoformat(),
            expected_payment_date.isoformat(),
            risk_level
        ])

        exposure_id += 1

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
            "fx_exposure_id",
            "trade_id",
            "currency_id",
            "exposure_amount",
            "spot_rate",
            "forward_rate",
            "potential_fx_loss",
            "exposure_date",
            "maturity_date",
            "risk_level"
        ])

        writer.writerows(rows)

    print("FX exposures generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(rows)}")


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    generate_fx_exposures()
    