import csv
from decimal import Decimal
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]

TRADES_FILE = PROJECT_ROOT / "data" / "raw" / "trades.csv"
OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "invoices.csv"

FIELDNAMES = [
    "invoice_id",
    "trade_id",
    "invoice_number",
    "invoice_date",
    "due_date",
    "invoice_amount",
    "currency_id",
    "invoice_status",
]

STATUS_MAP = {
    "COMPLETED": "PAID",
    "ACTIVE": "OPEN",
    "IN_TRANSIT": "OPEN",
    "PENDING": "PENDING",
}


def read_trades():
    with open(TRADES_FILE, "r", newline="", encoding="utf-8-sig") as file:
        reader = csv.DictReader(file)

        required_columns = {
            "trade_id",
            "currency_id",
            "trade_date",
            "expected_payment_date",
            "expected_revenue",
            "trade_status",
        }

        missing_columns = required_columns - set(reader.fieldnames or [])

        if missing_columns:
            raise ValueError(
                f"Trades CSV is missing required columns: {sorted(missing_columns)}"
            )

        return list(reader)


def generate_invoices():
    trades = read_trades()

    if not trades:
        raise ValueError("No trade records found. Invoice generation cancelled.")

    rows = []
    seen_trade_ids = set()

    for trade in trades:
        trade_id = int(trade["trade_id"])

        if trade_id in seen_trade_ids:
            raise ValueError(
                f"Duplicate trade_id {trade_id}. Invoice generation cancelled."
            )

        seen_trade_ids.add(trade_id)

        trade_status = trade["trade_status"]

        if trade_status not in STATUS_MAP:
            raise ValueError(
                f"Unsupported trade status '{trade_status}' for trade {trade_id}."
            )

        invoice_amount = Decimal(trade["expected_revenue"])

        if not invoice_amount.is_finite() or invoice_amount <= 0:
            raise ValueError(
                f"Invalid expected revenue for trade {trade_id}."
            )

        rows.append({
            "invoice_id": trade_id,
            "trade_id": trade_id,
            "invoice_number": f"INV-{trade_id:04d}",
            "invoice_date": trade["trade_date"],
            "due_date": trade["expected_payment_date"],
            "invoice_amount": f"{invoice_amount:.2f}",
            "currency_id": int(trade["currency_id"]),
            "invoice_status": STATUS_MAP[trade_status],
        })

    # Write only after all records have passed validation.
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=FIELDNAMES)
        writer.writeheader()
        writer.writerows(rows)

    print("Invoices generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(rows)}")


if __name__ == "__main__":
    generate_invoices()