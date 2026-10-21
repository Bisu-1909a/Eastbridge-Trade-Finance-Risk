import csv
from datetime import date
from pathlib import Path


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

EVENTS_FILE = (
    PROJECT_ROOT
    / "data"
    / "raw"
    / "operational_events.csv"
)

SHIPMENTS_FILE = (
    PROJECT_ROOT
    / "data"
    / "raw"
    / "shipments.csv"
)


# ============================================================
# Configuration
# ============================================================

VALID_EVENT_TYPES = {
    "DEPARTED",
    "CUSTOMS_CLEARANCE",
    "DELAY",
    "DELIVERED",
    "IN_TRANSIT_UPDATE"
}


# ============================================================
# Helpers
# ============================================================

def read_csv(path):

    with open(
        path,
        "r",
        encoding="utf-8"
    ) as file:

        return list(csv.DictReader(file))


def parse_date(value):

    return date.fromisoformat(value)


# ============================================================
# Validation
# ============================================================

def validate_operational_events():

    print("Validating EastBridge operational event data...\n")

    events = read_csv(EVENTS_FILE)
    shipments = read_csv(SHIPMENTS_FILE)

    # --------------------------------------------------------
    # Event count
    # --------------------------------------------------------

    assert len(events) > 100

    print(f"✓ Operational event count is {len(events)}.")

    # --------------------------------------------------------
    # Event IDs
    # --------------------------------------------------------

    event_ids = [
        int(row["operational_event_id"])
        for row in events
    ]

    assert len(event_ids) == len(set(event_ids))

    print("✓ Operational event IDs are unique.")

    # --------------------------------------------------------
    # Shipment references
    # --------------------------------------------------------

    shipment_ids = {
        int(row["shipment_id"])
        for row in shipments
    }

    event_shipment_ids = {
        int(row["shipment_id"])
        for row in events
    }

    assert event_shipment_ids.issubset(shipment_ids)

    print("✓ Operational event → Shipment references are valid.")

    # --------------------------------------------------------
    # Every shipment has at least one event
    # --------------------------------------------------------

    assert event_shipment_ids == shipment_ids

    print("✓ Every shipment has at least one operational event.")

    # --------------------------------------------------------
    # Event types
    # --------------------------------------------------------

    event_types = {
        row["event_type"]
        for row in events
    }

    assert event_types.issubset(VALID_EVENT_TYPES)

    print("✓ Operational event types are valid.")

    # --------------------------------------------------------
    # Event dates
    # --------------------------------------------------------

    shipment_lookup = {
        int(row["shipment_id"]): row
        for row in shipments
    }

    for event in events:

        shipment_id = int(
            event["shipment_id"]
        )

        event_date = parse_date(
            event["event_date"]
        )

        shipment_date = parse_date(
            shipment_lookup[shipment_id]["shipment_date"]
        )

        assert event_date >= shipment_date

    print("✓ Operational event dates are valid.")

    # --------------------------------------------------------
    # Every shipment must have DEPARTED event
    # --------------------------------------------------------

    for shipment_id in shipment_ids:

        shipment_events = [
            event
            for event in events
            if int(event["shipment_id"]) == shipment_id
        ]

        departed_events = [
            event
            for event in shipment_events
            if event["event_type"] == "DEPARTED"
        ]

        assert len(departed_events) == 1

    print("✓ Every shipment has exactly one departure event.")

    # --------------------------------------------------------
    # Delivered shipments must have DELIVERED event
    # --------------------------------------------------------

    for shipment in shipments:

        shipment_id = int(
            shipment["shipment_id"]
        )

        status = shipment["shipment_status"]

        shipment_events = [
            event
            for event in events
            if int(event["shipment_id"]) == shipment_id
        ]

        delivered_events = [
            event
            for event in shipment_events
            if event["event_type"] == "DELIVERED"
        ]

        if status in {"DELIVERED", "DELAYED"}:

            assert len(delivered_events) == 1

        else:

            assert len(delivered_events) == 0

    print("✓ Shipment delivery events match shipment statuses.")

    # --------------------------------------------------------
    # Delayed shipments must have DELAY event
    # --------------------------------------------------------

    for shipment in shipments:

        if shipment["shipment_status"] != "DELAYED":
            continue

        shipment_id = int(
            shipment["shipment_id"]
        )

        delay_events = [
            event
            for event in events
            if (
                int(event["shipment_id"]) == shipment_id
                and event["event_type"] == "DELAY"
            )
        ]

        assert len(delay_events) == 1

    print("✓ Delayed shipments have delay events.")

    # --------------------------------------------------------
    # In-transit shipments must have tracking event
    # --------------------------------------------------------

    for shipment in shipments:

        if shipment["shipment_status"] != "IN_TRANSIT":
            continue

        shipment_id = int(
            shipment["shipment_id"]
        )

        tracking_events = [
            event
            for event in events
            if (
                int(event["shipment_id"]) == shipment_id
                and event["event_type"] == "IN_TRANSIT_UPDATE"
            )
        ]

        assert len(tracking_events) == 1

    print("✓ In-transit shipments have tracking events.")

    # --------------------------------------------------------
    # Event descriptions
    # --------------------------------------------------------

    for event in events:

        assert event["event_description"].strip() != ""

    print("✓ Operational event descriptions are populated.")

    print("\nOperational event data validation passed.")


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    validate_operational_events()
    