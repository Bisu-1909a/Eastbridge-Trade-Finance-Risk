import csv
import random
from datetime import date, timedelta
from pathlib import Path


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

INVOICES_FILE = PROJECT_ROOT / "data" / "raw" / "invoices.csv"
TRADES_FILE = PROJECT_ROOT / "data" / "raw" / "trades.csv"

OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "payments.csv"


# ============================================================
# Configuration
# ============================================================

RANDOM_SEED = 42


# ============================================================
# Read CSV files
# ============================================================

def read_csv_file(file_path):

    with open(
        file_path,
        "r",
        encoding="utf-8"
    ) as file:

        return list(csv.DictReader(file))


# ============================================================
# Generate payments
# ============================================================

def generate_payments():

    random.seed(RANDOM_SEED)

    invoices = read_csv_file(INVOICES_FILE)
    trades = read_csv_file(TRADES_FILE)

    # --------------------------------------------------------
    # Create invoice → trade lookup
    # --------------------------------------------------------

    invoice_to_trade = {
        int(invoice["invoice_id"]): int(invoice["trade_id"])
        for invoice in invoices
    }

    # --------------------------------------------------------
    # Create trade → currency lookup
    # --------------------------------------------------------

    trade_to_currency = {
        int(trade["trade_id"]): int(trade["currency_id"])
        for trade in trades
    }

    rows = []

    payment_id = 1

    for invoice in invoices:

        invoice_id = int(invoice["invoice_id"])

        invoice_amount = float(
            invoice["invoice_amount"]
        )

        due_date = date.fromisoformat(
            invoice["due_date"]
        )

        invoice_status = invoice["invoice_status"]

        # ----------------------------------------------------
        # Determine trade and currency
        # ----------------------------------------------------

        trade_id = invoice_to_trade[invoice_id]

        currency_id = trade_to_currency[trade_id]

        # ----------------------------------------------------
        # Determine payment scenario
        # ----------------------------------------------------

        if invoice_status == "PAID":

            payment_status = "COMPLETED"

            payment_amount = invoice_amount

            # Payment may occur before the due date.
            payment_date = due_date - timedelta(
                days=random.randint(0, 20)
            )

        elif invoice_status == "OPEN":

            scenario = random.choice([
                "PARTIAL",
                "OVERDUE",
                "UNPAID"
            ])

            if scenario == "PARTIAL":

                payment_status = "PARTIAL"

                payment_amount = round(
                    invoice_amount * random.uniform(
                        0.30,
                        0.80
                    ),
                    2
                )

                payment_date = due_date + timedelta(
                    days=random.randint(1, 30)
                )

            elif scenario == "OVERDUE":

                payment_status = "OVERDUE"

                payment_amount = 0

                payment_date = due_date + timedelta(
                    days=random.randint(1, 45)
                )

            else:

                payment_status = "PENDING"

                payment_amount = 0

                payment_date = due_date

        else:

            payment_status = "PENDING"

            payment_amount = 0

            payment_date = due_date

        # ----------------------------------------------------
        # Payment method
        # ----------------------------------------------------

        payment_method = random.choice([
            "BANK_TRANSFER",
            "SWIFT",
            "LETTER_OF_CREDIT",
            "WIRE_TRANSFER"
        ])

        # ----------------------------------------------------
        # Store payment
        # ----------------------------------------------------

        rows.append([
            payment_id,
            invoice_id,
            payment_date.isoformat(),
            round(payment_amount, 2),
            currency_id,
            payment_method,
            payment_status
        ])

        payment_id += 1

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
            "payment_id",
            "invoice_id",
            "payment_date",
            "payment_amount",
            "currency_id",
            "payment_method",
            "payment_status"
        ])

        writer.writerows(rows)

    print("Payments generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(rows)}")


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    generate_payments()