import csv
from datetime import date
from pathlib import Path


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

PAYMENTS_FILE = PROJECT_ROOT / "data" / "raw" / "payments.csv"
INVOICES_FILE = PROJECT_ROOT / "data" / "raw" / "invoices.csv"
TRADES_FILE = PROJECT_ROOT / "data" / "raw" / "trades.csv"
CURRENCIES_FILE = PROJECT_ROOT / "data" / "raw" / "currencies.csv"


# ============================================================
# Helpers
# ============================================================

def read_csv(file_path):

    with open(
        file_path,
        "r",
        encoding="utf-8"
    ) as file:

        return list(csv.DictReader(file))


def assert_unique_ids(rows, column, label):

    ids = [row[column] for row in rows]

    assert len(ids) == len(set(ids)), (
        f"{label}: duplicate IDs found."
    )

    print(f"✓ {label}: IDs are unique.")


# ============================================================
# Validation
# ============================================================

def validate_payments():

    print("Validating EastBridge payment data...")
    print()

    payments = read_csv(PAYMENTS_FILE)
    invoices = read_csv(INVOICES_FILE)
    trades = read_csv(TRADES_FILE)
    currencies = read_csv(CURRENCIES_FILE)

    # --------------------------------------------------------
    # 1. Payment count
    # --------------------------------------------------------

    assert len(payments) == 100, (
        f"Expected 100 payments, found {len(payments)}."
    )

    print("✓ Payment count is 100.")

    # --------------------------------------------------------
    # 2. Payment IDs
    # --------------------------------------------------------

    assert_unique_ids(
        payments,
        "payment_id",
        "Payment"
    )

    # --------------------------------------------------------
    # 3. Payment → Invoice references
    # --------------------------------------------------------

    invoice_ids = {
        int(row["invoice_id"])
        for row in invoices
    }

    for payment in payments:

        invoice_id = int(payment["invoice_id"])

        assert invoice_id in invoice_ids, (
            f"Payment {payment['payment_id']} "
            f"references invalid invoice {invoice_id}."
        )

    print("✓ Payment → Invoice references are valid.")

    # --------------------------------------------------------
    # 4. Every invoice has exactly one payment
    # --------------------------------------------------------

    payment_invoice_ids = [
        int(row["invoice_id"])
        for row in payments
    ]

    assert set(payment_invoice_ids) == invoice_ids, (
        "Every invoice must have exactly one payment."
    )

    assert len(payment_invoice_ids) == len(
        set(payment_invoice_ids)
    ), (
        "Duplicate payment records found for an invoice."
    )

    print("✓ Every invoice has exactly one payment.")

    # --------------------------------------------------------
    # 5. Payment currencies match trade currencies
    # --------------------------------------------------------

    invoice_to_trade = {
        int(row["invoice_id"]): int(row["trade_id"])
        for row in invoices
    }

    trade_to_currency = {
        int(row["trade_id"]): int(row["currency_id"])
        for row in trades
    }

    for payment in payments:

        invoice_id = int(payment["invoice_id"])
        payment_currency = int(payment["currency_id"])

        trade_id = invoice_to_trade[invoice_id]

        expected_currency = trade_to_currency[trade_id]

        assert payment_currency == expected_currency, (
            f"Payment {payment['payment_id']} currency "
            f"does not match trade currency."
        )

    print("✓ Payment currencies match trade currencies.")

    # --------------------------------------------------------
    # 6. Currency references
    # --------------------------------------------------------

    currency_ids = {
        int(row["currency_id"])
        for row in currencies
    }

    for payment in payments:

        currency_id = int(payment["currency_id"])

        assert currency_id in currency_ids, (
            f"Payment {payment['payment_id']} "
            f"references invalid currency {currency_id}."
        )

    print("✓ Payment → Currency references are valid.")

    # --------------------------------------------------------
    # 7. Payment dates
    # --------------------------------------------------------

    invoice_lookup = {
        int(row["invoice_id"]): row
        for row in invoices
    }

    for payment in payments:

        payment_date = date.fromisoformat(
            payment["payment_date"]
        )

        invoice_id = int(payment["invoice_id"])

        invoice_date = date.fromisoformat(
            invoice_lookup[invoice_id]["invoice_date"]
        )

        assert payment_date >= invoice_date, (
            f"Payment {payment['payment_id']} "
            f"occurs before invoice date."
        )

    print("✓ Payment dates are valid.")

    # --------------------------------------------------------
    # 8. Payment amounts
    # --------------------------------------------------------

    for payment in payments:

        amount = float(
            payment["payment_amount"]
        )

        assert amount >= 0, (
            f"Payment {payment['payment_id']} "
            f"has a negative amount."
        )

        invoice_id = int(payment["invoice_id"])

        invoice_amount = float(
            invoice_lookup[invoice_id]["invoice_amount"]
        )

        assert amount <= invoice_amount, (
            f"Payment {payment['payment_id']} "
            f"exceeds invoice amount."
        )

    print("✓ Payment amounts are valid.")

    # --------------------------------------------------------
    # 9. Payment statuses
    # --------------------------------------------------------

    valid_statuses = {
        "PENDING",
        "PARTIAL",
        "OVERDUE",
        "COMPLETED"
    }

    for payment in payments:

        assert payment["payment_status"] in valid_statuses, (
            f"Invalid payment status: "
            f"{payment['payment_status']}"
        )

    print("✓ Payment statuses are valid.")

    # --------------------------------------------------------
    # 10. Completed payments must be fully paid
    # --------------------------------------------------------

    for payment in payments:

        if payment["payment_status"] == "COMPLETED":

            invoice_id = int(payment["invoice_id"])

            invoice_amount = float(
                invoice_lookup[invoice_id]["invoice_amount"]
            )

            payment_amount = float(
                payment["payment_amount"]
            )

            assert payment_amount == invoice_amount, (
                f"Completed payment {payment['payment_id']} "
                f"does not fully settle the invoice."
            )

    print("✓ Completed payments fully settle invoices.")

    print()
    print("Payment data validation passed.")


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":

    try:

        validate_payments()

    except AssertionError as error:

        print()
        print("Payment data validation failed.")
        print(error)

        raise SystemExit(1)
    