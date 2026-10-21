import csv
import random
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

FX_FILE = BASE_DIR / "data" / "raw" / "fx_exposures.csv"
OUTPUT_FILE = BASE_DIR / "data" / "raw" / "hedges.csv"


HEDGE_TYPES = [
    "FORWARD",
    "CURRENCY_OPTION",
    "CURRENCY_SWAP",
]

HEDGE_STATUSES = [
    "ACTIVE",
    "MATURED",
    "PARTIAL",
]


def main():

    print("Generating EastBridge hedge data...")

    with open(FX_FILE, "r", newline="", encoding="utf-8") as file:
        fx_records = list(csv.DictReader(file))

    print(f"Found {len(fx_records)} FX exposure records.")

    hedges = []

    random.seed(42)

    for hedge_id, fx in enumerate(fx_records, start=1):

        exposure_amount = float(fx["exposure_amount"])
        spot_rate = float(fx["spot_rate"])
        forward_rate = float(fx["forward_rate"])

        # Hedge between 60% and 100% of the FX exposure
        hedge_ratio = random.uniform(0.60, 1.00)

        hedged_amount = round(
            exposure_amount * hedge_ratio,
            2
        )

        # Slight variation around the forward rate
        hedge_rate = round(
            forward_rate * random.uniform(0.995, 1.005),
            4
        )

        # Determine status based on maturity
        if random.random() < 0.65:
            hedge_status = "ACTIVE"
        elif random.random() < 0.5:
            hedge_status = "PARTIAL"
        else:
            hedge_status = "MATURED"

        hedges.append({
            "hedge_id": hedge_id,
            "fx_exposure_id": fx["fx_exposure_id"],
            "hedge_date": fx["exposure_date"],
            "hedge_type": random.choice(HEDGE_TYPES),
            "hedged_amount": hedged_amount,
            "hedge_rate": hedge_rate,
            "hedge_status": hedge_status,
        })

    with open(
        OUTPUT_FILE,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:

        fieldnames = [
            "hedge_id",
            "fx_exposure_id",
            "hedge_date",
            "hedge_type",
            "hedged_amount",
            "hedge_rate",
            "hedge_status",
        ]

        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames
        )

        writer.writeheader()
        writer.writerows(hedges)

    print(f"Hedges generated successfully: {len(hedges)}")


if __name__ == "__main__":
    main()