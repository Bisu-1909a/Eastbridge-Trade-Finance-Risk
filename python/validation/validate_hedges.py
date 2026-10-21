import csv
from pathlib import Path
from datetime import datetime


BASE_DIR = Path(__file__).resolve().parents[2]

HEDGE_FILE = BASE_DIR / "data" / "raw" / "hedges.csv"
FX_FILE = BASE_DIR / "data" / "raw" / "fx_exposures.csv"


VALID_HEDGE_TYPES = {
    "FORWARD",
    "CURRENCY_OPTION",
    "CURRENCY_SWAP",
}

VALID_HEDGE_STATUSES = {
    "ACTIVE",
    "PARTIAL",
    "MATURED",
}


def parse_date(value):
    return datetime.strptime(value, "%Y-%m-%d").date()


def main():

    print("Validating EastBridge hedge data...\n")

    with open(HEDGE_FILE, "r", newline="", encoding="utf-8") as file:
        hedges = list(csv.DictReader(file))

    with open(FX_FILE, "r", newline="", encoding="utf-8") as file:
        fx_exposures = list(csv.DictReader(file))

    # ---------------------------------------------------------
    # 1. Hedge count
    # ---------------------------------------------------------

    assert len(hedges) == 100, \
        f"Expected 100 hedges, found {len(hedges)}."

    print("✓ Hedge count is 100.")

    # ---------------------------------------------------------
    # 2. Hedge IDs
    # ---------------------------------------------------------

    hedge_ids = [int(row["hedge_id"]) for row in hedges]

    assert len(hedge_ids) == len(set(hedge_ids)), \
        "Duplicate hedge IDs found."

    print("✓ Hedge IDs are unique.")

    # ---------------------------------------------------------
    # 3. FX exposure references
    # ---------------------------------------------------------

    fx_ids = {
        int(row["fx_exposure_id"])
        for row in fx_exposures
    }

    for hedge in hedges:

        fx_exposure_id = int(hedge["fx_exposure_id"])

        assert fx_exposure_id in fx_ids, \
            f"Invalid FX exposure reference: {fx_exposure_id}"

    print("✓ Hedge → FX exposure references are valid.")

    # ---------------------------------------------------------
    # 4. Every FX exposure has exactly one hedge
    # ---------------------------------------------------------

    hedge_fx_ids = [
        int(row["fx_exposure_id"])
        for row in hedges
    ]

    assert len(hedge_fx_ids) == len(set(hedge_fx_ids)), \
        "Some FX exposures have multiple hedges."

    assert set(hedge_fx_ids) == fx_ids, \
        "Not every FX exposure has exactly one hedge."

    print("✓ Every FX exposure has exactly one hedge.")

    # ---------------------------------------------------------
    # 5. Hedge dates
    # ---------------------------------------------------------

    fx_by_id = {
        int(row["fx_exposure_id"]): row
        for row in fx_exposures
    }

    for hedge in hedges:

        fx_id = int(hedge["fx_exposure_id"])

        hedge_date = parse_date(hedge["hedge_date"])
        exposure_date = parse_date(
            fx_by_id[fx_id]["exposure_date"]
        )

        assert hedge_date == exposure_date, \
            f"Hedge date mismatch for FX exposure {fx_id}."

    print("✓ Hedge dates match FX exposure dates.")

    # ---------------------------------------------------------
    # 6. Hedged amounts
    # ---------------------------------------------------------

    for hedge in hedges:

        amount = float(hedge["hedged_amount"])

        fx_id = int(hedge["fx_exposure_id"])

        exposure_amount = float(
            fx_by_id[fx_id]["exposure_amount"]
        )

        assert amount > 0, \
            f"Invalid hedged amount for hedge {hedge['hedge_id']}."

        assert amount <= exposure_amount, \
            f"Hedged amount exceeds exposure for hedge {hedge['hedge_id']}."

    print("✓ Hedged amounts are valid.")

    # ---------------------------------------------------------
    # 7. Hedge rates
    # ---------------------------------------------------------

    for hedge in hedges:

        hedge_rate = float(hedge["hedge_rate"])

        assert hedge_rate > 0, \
            f"Invalid hedge rate for hedge {hedge['hedge_id']}."

    print("✓ Hedge rates are valid.")

    # ---------------------------------------------------------
    # 8. Hedge types
    # ---------------------------------------------------------

    for hedge in hedges:

        assert hedge["hedge_type"] in VALID_HEDGE_TYPES, \
            f"Invalid hedge type: {hedge['hedge_type']}"

    print("✓ Hedge types are valid.")

    # ---------------------------------------------------------
    # 9. Hedge statuses
    # ---------------------------------------------------------

    for hedge in hedges:

        assert hedge["hedge_status"] in VALID_HEDGE_STATUSES, \
            f"Invalid hedge status: {hedge['hedge_status']}"

    print("✓ Hedge statuses are valid.")

    print("\nHedge data validation passed.")


if __name__ == "__main__":
    main()