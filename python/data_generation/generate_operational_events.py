import csv
import random
from datetime import date, timedelta
from pathlib import Path


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

SHIPMENTS_FILE = PROJECT_ROOT / "data" / "raw" / "shipments.csv"
OUTPUT_FILE = PROJECT_ROOT / "data" / "raw" / "operational_events.csv"


# ============================================================
# Configuration
# ============================================================

RANDOM_SEED = 42


# ============================================================
# Read shipments
# ============================================================

def read_shipments():

    with open(
        SHIPMENTS_FILE,
        "r",
        encoding="utf-8"
    ) as file:

        return list(csv.DictReader(file))


# ============================================================
# Generate operational events
# ============================================================

def generate_operational_events():

    random.seed(RANDOM_SEED)

    shipments = read_shipments()

    rows = []

    operational_event_id = 1

    for shipment in shipments:

        shipment_id = int(shipment["shipment_id"])

        shipment_date = date.fromisoformat(
            shipment["shipment_date"]
        )

        expected_arrival_date = date.fromisoformat(
            shipment["expected_arrival_date"]
        )

        actual_arrival_value = shipment["actual_arrival_date"]

        # ----------------------------------------------------
        # Every shipment gets a departure event
        # ----------------------------------------------------

        rows.append([
            operational_event_id,
            shipment_id,
            "DEPARTED",
            shipment_date.isoformat(),
            "Shipment departed from origin."
        ])

        operational_event_id += 1

        # ----------------------------------------------------
        # Some shipments experience customs events
        # ----------------------------------------------------

        if random.random() < 0.35:

            customs_date = (
                shipment_date
                + timedelta(
                    days=random.randint(1, 7)
                )
            )

            rows.append([
                operational_event_id,
                shipment_id,
                "CUSTOMS_CLEARANCE",
                customs_date.isoformat(),
                "Shipment underwent customs clearance."
            ])

            operational_event_id += 1

        # ----------------------------------------------------
        # Delayed shipments receive a delay event
        # ----------------------------------------------------

        if shipment["shipment_status"] == "DELAYED":

            delay_date = (
                expected_arrival_date
                - timedelta(
                    days=random.randint(1, 5)
                )
            )

            rows.append([
                operational_event_id,
                shipment_id,
                "DELAY",
                delay_date.isoformat(),
                "Shipment experienced an operational delay."
            ])

            operational_event_id += 1

        # ----------------------------------------------------
        # Delivered shipments receive arrival event
        # ----------------------------------------------------

        if shipment["shipment_status"] == "DELIVERED":

            actual_arrival_date = date.fromisoformat(
                actual_arrival_value
            )

            rows.append([
                operational_event_id,
                shipment_id,
                "DELIVERED",
                actual_arrival_date.isoformat(),
                "Shipment successfully delivered."
            ])

            operational_event_id += 1

        # ----------------------------------------------------
        # Delayed shipments eventually arrive
        # ----------------------------------------------------

        elif shipment["shipment_status"] == "DELAYED":

            actual_arrival_date = date.fromisoformat(
                actual_arrival_value
            )

            rows.append([
                operational_event_id,
                shipment_id,
                "DELIVERED",
                actual_arrival_date.isoformat(),
                "Shipment delivered after operational delay."
            ])

            operational_event_id += 1

        # ----------------------------------------------------
        # In-transit shipments receive tracking event
        # ----------------------------------------------------

        elif shipment["shipment_status"] == "IN_TRANSIT":

            tracking_date = (
                shipment_date
                + timedelta(
                    days=random.randint(1, 10)
                )
            )

            rows.append([
                operational_event_id,
                shipment_id,
                "IN_TRANSIT_UPDATE",
                tracking_date.isoformat(),
                "Shipment remains in transit."
            ])

            operational_event_id += 1

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
            "operational_event_id",
            "shipment_id",
            "event_type",
            "event_date",
            "event_description"
        ])

        writer.writerows(rows)

    print("Operational events generated successfully.")
    print(f"File: {OUTPUT_FILE}")
    print(f"Records: {len(rows)}")


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    generate_operational_events()
    