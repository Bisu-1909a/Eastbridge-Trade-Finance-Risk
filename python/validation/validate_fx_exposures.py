import csv
import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[2]

DB_PATH = BASE_DIR / "database" / "eastbridge.db"
FX_FILE = BASE_DIR / "data" / "raw" / "fx_exposures.csv"


VALID_RISK_LEVELS = {"LOW", "MEDIUM", "HIGH"}


def load_csv():
    with open(FX_FILE, "r", encoding="utf-8") as file:
        return list(csv.DictReader(file))


def main():
    print("Validating EastBridge FX exposure data...\n")

    rows = load_csv()

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # --------------------------------------------------
    # 1. Record count
    # --------------------------------------------------

    assert len(rows) == 100, f"Expected 100 FX exposures, found {len(rows)}."
    print("✓ FX exposure count is 100.")

    # --------------------------------------------------
    # 2. Unique IDs
    # --------------------------------------------------

    exposure_ids = [int(row["fx_exposure_id"]) for row in rows]

    assert len(exposure_ids) == len(set(exposure_ids)), \
        "Duplicate FX exposure IDs found."

    print("✓ FX exposure IDs are unique.")

    # --------------------------------------------------
    # 3. Trade references
    # --------------------------------------------------

    trade_ids = {
        row[0]
        for row in cursor.execute(
            "SELECT trade_id FROM trade"
        ).fetchall()
    }

    for row in rows:
        trade_id = int(row["trade_id"])

        assert trade_id in trade_ids, \
            f"Invalid trade reference: {trade_id}"

    print("✓ FX exposure → Trade references are valid.")

    # --------------------------------------------------
    # 4. One FX exposure per trade
    # --------------------------------------------------

    counts = {}

    for row in rows:
        trade_id = int(row["trade_id"])
        counts[trade_id] = counts.get(trade_id, 0) + 1

    assert len(counts) == 100, \
        "Not every trade has an FX exposure."

    assert all(count == 1 for count in counts.values()), \
        "Some trades have multiple FX exposures."

    print("✓ Every trade has exactly one FX exposure.")

    # --------------------------------------------------
    # 5. Currency references
    # --------------------------------------------------

    currency_ids = {
        row[0]
        for row in cursor.execute(
            "SELECT currency_id FROM currency"
        ).fetchall()
    }

    for row in rows:
        currency_id = int(row["currency_id"])

        assert currency_id in currency_ids, \
            f"Invalid currency reference: {currency_id}"

    print("✓ FX exposure → Currency references are valid.")

    # --------------------------------------------------
    # 6. Currency matches trade currency
    # --------------------------------------------------

    trade_currency = {
        row[0]: row[1]
        for row in cursor.execute(
            "SELECT trade_id, currency_id FROM trade"
        ).fetchall()
    }

    for row in rows:
        trade_id = int(row["trade_id"])
        currency_id = int(row["currency_id"])

        assert trade_currency[trade_id] == currency_id, (
            f"Currency mismatch for trade {trade_id}."
        )

    print("✓ FX exposure currencies match trade currencies.")

    # --------------------------------------------------
    # 7. Exposure amount matches trade revenue
    # --------------------------------------------------

    trade_revenue = {
        row[0]: float(row[1])
        for row in cursor.execute(
            "SELECT trade_id, expected_revenue FROM trade"
        ).fetchall()
    }

    for row in rows:
        trade_id = int(row["trade_id"])
        exposure_amount = float(row["exposure_amount"])

        assert abs(exposure_amount - trade_revenue[trade_id]) < 0.01, (
            f"Exposure amount mismatch for trade {trade_id}."
        )

    print("✓ Exposure amounts match trade revenue.")

    # --------------------------------------------------
    # 8. Exposure date matches trade date
    # --------------------------------------------------

    trade_dates = {
        row[0]: row[1]
        for row in cursor.execute(
            "SELECT trade_id, trade_date FROM trade"
        ).fetchall()
    }

    for row in rows:
        trade_id = int(row["trade_id"])

        assert row["exposure_date"] == trade_dates[trade_id], (
            f"Exposure date mismatch for trade {trade_id}."
        )

    print("✓ Exposure dates match trade dates.")

    # --------------------------------------------------
    # 9. Maturity date matches expected payment date
    # --------------------------------------------------

    trade_payment_dates = {
        row[0]: row[1]
        for row in cursor.execute(
            "SELECT trade_id, expected_payment_date FROM trade"
        ).fetchall()
    }

    for row in rows:
        trade_id = int(row["trade_id"])

        assert row["maturity_date"] == trade_payment_dates[trade_id], (
            f"Maturity date mismatch for trade {trade_id}."
        )

    print("✓ Maturity dates match expected payment dates.")

    # --------------------------------------------------
    # 10. FX rates are positive
    # --------------------------------------------------

    for row in rows:
        spot_rate = float(row["spot_rate"])
        forward_rate = float(row["forward_rate"])

        assert spot_rate > 0, \
            f"Invalid spot rate for exposure {row['fx_exposure_id']}."

        assert forward_rate > 0, \
            f"Invalid forward rate for exposure {row['fx_exposure_id']}."

    print("✓ Spot and forward rates are valid.")

    # --------------------------------------------------
    # 11. Potential FX loss
    # --------------------------------------------------

    for row in rows:
        potential_loss = float(row["potential_fx_loss"])

        assert potential_loss >= 0, (
            f"Negative potential FX loss for exposure "
            f"{row['fx_exposure_id']}."
        )

    print("✓ Potential FX losses are valid.")

    # --------------------------------------------------
    # 12. Risk levels
    # --------------------------------------------------

    for row in rows:
        assert row["risk_level"] in VALID_RISK_LEVELS, (
            f"Invalid risk level: {row['risk_level']}"
        )

    print("✓ FX risk levels are valid.")

    conn.close()

    print("\nFX exposure data validation passed.")


if __name__ == "__main__":
    main()
    