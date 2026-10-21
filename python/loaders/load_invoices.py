import csv
import sqlite3
from decimal import Decimal, InvalidOperation
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DB_PATH = PROJECT_ROOT / "database" / "eastbridge.db"
CSV_PATH = PROJECT_ROOT / "data" / "raw" / "invoices.csv"

EXPECTED_HEADERS = [
    "invoice_id",
    "trade_id",
    "invoice_number",
    "invoice_date",
    "due_date",
    "invoice_amount",
    "currency_id",
    "invoice_status",
]


def read_and_validate_csv():
    if not CSV_PATH.is_file():
        raise FileNotFoundError(f"Invoice CSV not found: {CSV_PATH}")

    with CSV_PATH.open("r", newline="", encoding="utf-8-sig") as file:
        reader = csv.DictReader(file)

        if reader.fieldnames != EXPECTED_HEADERS:
            raise ValueError(
                f"Unexpected invoice CSV columns: {reader.fieldnames}"
            )

        rows = []
        seen_ids = set()
        seen_numbers = set()

        for line_number, row in enumerate(reader, start=2):
            try:
                invoice_id = int(row["invoice_id"])
                trade_id = int(row["trade_id"])
                currency_id = int(row["currency_id"])
                invoice_number = row["invoice_number"].strip()
                invoice_date = row["invoice_date"].strip()
                due_date = row["due_date"].strip() or None
                amount = Decimal(row["invoice_amount"])
                status = row["invoice_status"].strip()

                if min(invoice_id, trade_id, currency_id) <= 0:
                    raise ValueError("IDs must be positive integers")

                if not invoice_number or not invoice_date or not status:
                    raise ValueError(
                        "Invoice number, date, and status are required"
                    )

                if not amount.is_finite() or amount <= 0:
                    raise ValueError(
                        "Invoice amount must be positive and finite"
                    )

                if invoice_id in seen_ids:
                    raise ValueError(f"Duplicate invoice_id: {invoice_id}")

                if invoice_number in seen_numbers:
                    raise ValueError(
                        f"Duplicate invoice_number: {invoice_number}"
                    )

                seen_ids.add(invoice_id)
                seen_numbers.add(invoice_number)

                rows.append((
                    invoice_id,
                    trade_id,
                    invoice_number,
                    invoice_date,
                    due_date,
                    str(amount),
                    currency_id,
                    status,
                ))

            except (ValueError, InvalidOperation, TypeError) as exc:
                raise ValueError(
                    f"Invalid invoice data at CSV line {line_number}: {exc}"
                ) from exc

    if not rows:
        raise ValueError("Invoice CSV contains no data rows")

    return rows


def main():
    if not DB_PATH.is_file():
        raise FileNotFoundError(f"Database not found: {DB_PATH}")

    rows = read_and_validate_csv()
    print(f"Validated invoice records: {len(rows)}")

    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("PRAGMA foreign_keys = ON")

        if conn.execute("PRAGMA foreign_keys").fetchone()[0] != 1:
            raise RuntimeError("Foreign-key enforcement is disabled")

        existing = conn.execute(
            "SELECT COUNT(*) FROM invoice"
        ).fetchone()[0]

        if existing:
            raise RuntimeError(
                f"STOP: Invoice table already contains {existing} rows. "
                "No invoices were inserted."
            )

        for invoice_id, trade_id, _, _, _, _, currency_id, _ in rows:
            if conn.execute(
                "SELECT 1 FROM trade WHERE trade_id = ?", (trade_id,)
            ).fetchone() is None:
                raise ValueError(
                    f"Invoice {invoice_id} references missing trade {trade_id}"
                )

            if conn.execute(
                "SELECT 1 FROM currency WHERE currency_id = ?",
                (currency_id,),
            ).fetchone() is None:
                raise ValueError(
                    f"Invoice {invoice_id} references missing currency "
                    f"{currency_id}"
                )

        conn.executemany(
            """
            INSERT INTO invoice (
                invoice_id, trade_id, invoice_number, invoice_date,
                due_date, invoice_amount, currency_id, invoice_status
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )

        violations = conn.execute("PRAGMA foreign_key_check").fetchall()

        if violations:
            raise RuntimeError(
                f"Foreign-key validation failed: {violations[:10]}"
            )

        final_count = conn.execute(
            "SELECT COUNT(*) FROM invoice"
        ).fetchone()[0]

        if final_count != len(rows):
            raise RuntimeError(
                f"Expected {len(rows)} invoices, found {final_count}"
            )

        print(f"Invoices loaded successfully: {final_count}")
        print("PASS - Invoice loader checks completed.")


if __name__ == "__main__":
    main()
