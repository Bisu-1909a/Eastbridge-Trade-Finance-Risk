import sqlite3
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]

SCHEMA_FILE = PROJECT_ROOT / "sql" / "schema" / "schema.sql"


def validate_relationships():
    schema = SCHEMA_FILE.read_text(encoding="utf-8")

    connection = sqlite3.connect(":memory:")
    connection.execute("PRAGMA foreign_keys = ON")

    try:
        connection.executescript(schema)

        print("Schema loaded successfully.")
        print("Foreign-key enforcement is ON.")

        # Test 1: Country → Customer
        connection.execute("""
            INSERT INTO country
            (country_id, country_code, country_name)
            VALUES (1, 'IN', 'India')
        """)

        connection.execute("""
            INSERT INTO customer
            (customer_id, customer_name, country_id)
            VALUES (1, 'Test Customer', 1)
        """)

        print("✓ Country → Customer relationship works.")

        # Test 2: Currency → Trade
        connection.execute("""
            INSERT INTO currency
            (currency_id, currency_code, currency_name)
            VALUES (1, 'USD', 'US Dollar')
        """)

        connection.execute("""
            INSERT INTO supplier
            (supplier_id, supplier_name, country_id)
            VALUES (1, 'Test Supplier', 1)
        """)

        connection.execute("""
            INSERT INTO product
            (product_id, product_name, product_category)
            VALUES (1, 'Test Product', 'Test Category')
        """)

        connection.execute("""
            INSERT INTO route
            (
                route_id,
                origin_country_id,
                destination_country_id,
                route_name
            )
            VALUES (1, 1, 1, 'Test Route')
        """)

        connection.execute("""
            INSERT INTO trade
            (
                trade_id,
                customer_id,
                supplier_id,
                product_id,
                route_id,
                currency_id,
                trade_date,
                trade_status
            )
            VALUES
            (1, 1, 1, 1, 1, 1, '2026-01-01', 'ACTIVE')
        """)

        print("✓ Master tables → Trade relationships work.")

        # Test 3: Trade → Invoice → Payment
        connection.execute("""
            INSERT INTO invoice
            (
                invoice_id,
                trade_id,
                invoice_number,
                invoice_date,
                currency_id
            )
            VALUES
            (1, 1, 'INV-001', '2026-01-02', 1)
        """)

        connection.execute("""
            INSERT INTO payment
            (
                payment_id,
                invoice_id,
                payment_date,
                currency_id
            )
            VALUES
            (1, 1, '2026-01-10', 1)
        """)

        print("✓ Trade → Invoice → Payment relationships work.")

        # Test 4: Trade → Shipment → Operational Event
        connection.execute("""
            INSERT INTO shipment
            (
                shipment_id,
                trade_id,
                shipment_date
            )
            VALUES
            (1, 1, '2026-01-03')
        """)

        connection.execute("""
            INSERT INTO operational_event
            (
                operational_event_id,
                shipment_id,
                event_type,
                event_date
            )
            VALUES
            (1, 1, 'CUSTOMS_DELAY', '2026-01-05')
        """)

        print("✓ Trade → Shipment → Operational Event relationships work.")

        # Test 5: Trade → FX Exposure → Hedge
        connection.execute("""
            INSERT INTO fx_exposure
            (
                fx_exposure_id,
                trade_id,
                currency_id,
                exposure_direction
            )
            VALUES
            (1, 1, 1, 'BUY')
        """)

        connection.execute("""
            INSERT INTO hedge
            (
                hedge_id,
                fx_exposure_id,
                hedge_date,
                hedge_type
            )
            VALUES
            (1, 1, '2026-01-04', 'FORWARD')
        """)

        print("✓ Trade → FX Exposure → Hedge relationships work.")

        print("\nAll relationship tests passed.")

    except sqlite3.Error as error:
        print("\nRelationship validation failed.")
        print(error)

    finally:
        connection.close()


if __name__ == "__main__":
    validate_relationships()
    
