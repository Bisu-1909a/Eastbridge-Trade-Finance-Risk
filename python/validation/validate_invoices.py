import csv
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA = PROJECT_ROOT / "data" / "raw"


def read_csv(filename):
    file_path = RAW_DATA / filename

    with open(file_path, "r", encoding="utf-8") as file:
        return list(csv.DictReader(file))


def validate_invoice_ids(invoices):
    invoice_ids = [row["invoice_id"] for row in invoices]

    if len(invoice_ids) != len(set(invoice_ids)):
        raise ValueError("Duplicate invoice_id found.")

    print("✓ Invoice IDs are unique.")


def validate_trade_references(invoices, trades):
    trade_ids = {row["trade_id"] for row in trades}

    for invoice in invoices:
        if invoice["trade_id"] not in trade_ids:
            raise ValueError(
                f"Invalid trade_id {invoice['trade_id']} "
                f"for invoice {invoice['invoice_id']}."
            )

    print("✓ Invoice → Trade references are valid.")


def validate_one_invoice_per_trade(invoices, trades):
    invoice_trade_ids = [row["trade_id"] for row in invoices]
    trade_ids = [row["trade_id"] for row in trades]

    if len(invoice_trade_ids) != len(trade_ids):
        raise ValueError(
            "Invoice count does not match trade count."
        )

    if set(invoice_trade_ids) != set(trade_ids):
        raise ValueError(
            "Not every trade has exactly one invoice."
        )

    print("✓ Every trade has exactly one invoice.")


def validate_amounts(invoices, trades):
    trade_amounts = {
        row["trade_id"]: float(row["expected_revenue"])
        for row in trades
    }

    for invoice in invoices:
        invoice_amount = float(invoice["invoice_amount"])
        expected_amount = trade_amounts[invoice["trade_id"]]

        if invoice_amount != expected_amount:
            raise ValueError(
                f"Invoice amount mismatch for invoice "
                f"{invoice['invoice_id']}."
            )

        if invoice_amount <= 0:
            raise ValueError(
                f"Invalid invoice amount for invoice "
                f"{invoice['invoice_id']}."
            )

    print("✓ Invoice amounts match trade revenue.")


def validate_statuses(invoices):
    valid_statuses = {
        "OPEN",
        "PAID",
        "PENDING"
    }

    for invoice in invoices:
        if invoice["invoice_status"] not in valid_statuses:
            raise ValueError(
                f"Invalid invoice status "
                f"{invoice['invoice_status']} "
                f"for invoice {invoice['invoice_id']}."
            )

    print("✓ Invoice statuses are valid.")


def validate_dates(invoices):
    for invoice in invoices:
        if invoice["due_date"] < invoice["invoice_date"]:
            raise ValueError(
                f"Due date is before invoice date "
                f"for invoice {invoice['invoice_id']}."
            )

    print("✓ Invoice dates are valid.")


def validate_invoices():
    print("Validating EastBridge invoice data...\n")

    invoices = read_csv("invoices.csv")
    trades = read_csv("trades.csv")

    if len(invoices) != 100:
        raise ValueError(
            f"Expected 100 invoices, found {len(invoices)}."
        )

    print("✓ Invoice count is 100.")

    validate_invoice_ids(invoices)

    validate_trade_references(
        invoices,
        trades
    )

    validate_one_invoice_per_trade(
        invoices,
        trades
    )

    validate_amounts(
        invoices,
        trades
    )

    validate_statuses(invoices)

    validate_dates(invoices)

    print("\nInvoice data validation passed.")


if __name__ == "__main__":
    validate_invoices()
    