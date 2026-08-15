# EastBridge Trade Finance — Logical Data Model

## 1. Purpose

This document translates the approved conceptual data model into a logical relational structure for the EastBridge Trade Finance analytics project.

The logical model defines:

- Logical entities
- Primary keys
- Foreign keys
- Important attributes
- Relationships
- Table grain
- Expected vs. actual data separation
- Derived analytical values

This model will be used as the foundation for the physical database schema and subsequent SQL implementation.

---

## 2. Design Principles

The logical model follows these principles:

1. Every table must have a clear business grain.
2. Every entity must have a stable primary key.
3. Relationships are represented through foreign keys.
4. Repeating business events are stored as separate records rather than repeated columns.
5. Expected commercial values are separated from actual financial and operational events.
6. Derived analytical measures such as realized profit and leakage are calculated rather than stored as independent source records.
7. Reference data such as countries, currencies, products, and routes is standardized.
8. The model should remain the smallest realistic structure capable of answering the approved EastBridge business questions.

---

# 3. Logical Entity Inventory

## 3.1 Master Data

### Customer

**Grain:** One row represents one customer.

| Attribute | Key | Description |
|---|---|---|
| customer_id | PK | Unique customer identifier |
| customer_name | | Customer name |
| country_id | FK | Customer's country |
| industry | | Customer industry |
| customer_segment | | Customer segment |

---

### Supplier

**Grain:** One row represents one supplier.

| Attribute | Key | Description |
|---|---|---|
| supplier_id | PK | Unique supplier identifier |
| supplier_name | | Supplier name |
| country_id | FK | Supplier's country |
| supplier_type | | Supplier classification |

---

### Country

**Grain:** One row represents one standardized country.

| Attribute | Key | Description |
|---|---|---|
| country_id | PK | Unique country identifier |
| country_code | | Standard country code |
| country_name | | Country name |

---

### Currency

**Grain:** One row represents one standardized currency.

| Attribute | Key | Description |
|---|---|---|
| currency_id | PK | Unique currency identifier |
| currency_code | | Standard currency code |
| currency_name | | Currency name |

---

### Product

**Grain:** One row represents one product or product category.

| Attribute | Key | Description |
|---|---|---|
| product_id | PK | Unique product identifier |
| product_name | | Product name |
| product_category | | Product classification |

---

### Route

**Grain:** One row represents one standardized trade/logistics corridor.

| Attribute | Key | Description |
|---|---|---|
| route_id | PK | Unique route identifier |
| origin_country_id | FK | Origin country |
| destination_country_id | FK | Destination country |
| route_name | | Human-readable route/corridor name |

Both `origin_country_id` and `destination_country_id` reference `country.country_id`.

---

# 4. Core Commercial Entity

## Trade

**Grain:** One row represents one commercial trade.

| Attribute | Key | Description |
|---|---|---|
| trade_id | PK | Unique trade identifier |
| customer_id | FK | Customer associated with the trade |
| supplier_id | FK | Supplier associated with the trade |
| product_id | FK | Product associated with the trade |
| route_id | FK | Trade route |
| currency_id | FK | Primary trade currency |
| trade_date | | Trade initiation/approval date |
| trade_status | | Current trade lifecycle status |
| expected_revenue | | Expected revenue at trade level |
| expected_procurement_cost | | Expected procurement cost |
| expected_operational_cost | | Expected operational cost |
| expected_shipment_date | | Expected shipment date |
| expected_payment_date | | Expected payment date |

Trade represents the expected/commercial picture against which actual events will later be evaluated.

---

# 5. Financial Entities

## Invoice

**Grain:** One row represents one invoice.

| Attribute | Key | Description |
|---|---|---|
| invoice_id | PK | Unique invoice identifier |
| trade_id | FK | Trade associated with the invoice |
| invoice_number | | Business invoice reference |
| invoice_date | | Invoice issue date |
| due_date | | Payment due date |
| invoice_amount | | Invoice amount |
| currency_id | FK | Invoice currency |
| invoice_status | | Invoice lifecycle/status |

> **Currency note:** Invoice currency represents the denomination of the invoice and may differ from the primary trade currency.

---

## Payment

**Grain:** One row represents one payment event.

| Attribute | Key | Description |
|---|---|---|
| payment_id | PK | Unique payment identifier |
| invoice_id | FK | Invoice associated with the payment |
| payment_date | | Date of payment |
| payment_amount | | Payment amount |
| currency_id | FK | Payment currency |
| payment_method | | Payment method |
| payment_status | | Payment status |

> **Currency note:** Payment currency represents the currency in which the actual payment was made. It is intentionally stored independently from the trade and invoice currencies to support settlement and FX analysis.

Multiple payments may be associated with one invoice.

---

## Financial Event

**Grain:** One row represents one actual financial event associated with a trade.

| Attribute | Key | Description |
|---|---|---|
| financial_event_id | PK | Unique financial event identifier |
| trade_id | FK | Trade associated with the event |
| event_type | | Type of financial event |
| event_date | | Date of financial event |
| amount | | Financial event amount |
| currency_id | FK | Currency of the event |
| description | | Description of the event |

> Financial events represent actual financial outcomes associated with a trade. They are not expected values and should not contain derived measures such as profit or leakage.

Expected event types may include:

- REVENUE
- PROCUREMENT_COST
- OPERATIONAL_COST
- OTHER_COST

Financial events represent actual financial outcomes.

---

# 6. Operational Entities

## Shipment

**Grain:** One row represents one shipment.

| Attribute | Key | Description |
|---|---|---|
| shipment_id | PK | Unique shipment identifier |
| trade_id | FK | Trade associated with the shipment |
| shipment_date | | Actual shipment date |
| expected_arrival_date | | Expected arrival date |
| actual_arrival_date | | Actual arrival date |
| shipment_status | | Shipment status |

A trade may contain multiple shipments.

---

## Operational Event

**Grain:** One row represents one operational event associated with a shipment.

| Attribute | Key | Description |
|---|---|---|
| operational_event_id | PK | Unique operational event identifier |
| shipment_id | FK | Shipment associated with the event |
| event_type | | Operational event type |
| event_date | | Event date |
| event_description | | Description of the event |

Examples include:

- CUSTOMS_DELAY
- PORT_CONGESTION
- DOCUMENTATION_ISSUE
- CARRIER_DELAY
- INSPECTION_DELAY
- SUPPLIER_READINESS_DELAY

Operational events allow multiple issues to be recorded for a single shipment.

---

# 7. Foreign Exchange Entities

## FX Exposure

**Grain:** One row represents one identifiable FX exposure associated with a trade.

| Attribute | Key | Description |
|---|---|---|
| fx_exposure_id | PK | Unique FX exposure identifier |
| trade_id | FK | Trade associated with the exposure |
| currency_id | FK | Exposure currency |
| exposure_direction | | Direction of FX exposure |
| exposure_amount | | Amount exposed |
| exposure_start_date | | Exposure start date |
| expected_settlement_date | | Expected settlement date |

---

## FX Rate

**Grain:** One row represents one FX rate observation for one currency/date combination.

| Attribute | Key | Description |
|---|---|---|
| fx_rate_id | PK | Unique FX rate observation identifier |
| currency_id | FK | Currency represented by the rate |
| rate_date | | Date of the FX rate |
| exchange_rate | | Observed exchange rate |

The logical business key is:

`currency_id + rate_date`

This combination should be unique in the physical schema.

---

## Hedge

**Grain:** One row represents one hedge arrangement associated with an FX exposure.

| Attribute | Key | Description |
|---|---|---|
| hedge_id | PK | Unique hedge identifier |
| fx_exposure_id | FK | FX exposure being hedged |
| hedge_date | | Hedge execution date |
| hedge_type | | Type of hedge |
| hedged_amount | | Amount hedged |
| hedge_rate | | Executed hedge rate |
| hedge_status | | Hedge status |

One FX exposure may have multiple hedge arrangements.

---

# 8. Relationship Summary

| Parent Entity | Child Entity | Cardinality |
|---|---|---|
| Country | Customer | 1:M |
| Country | Supplier | 1:M |
| Country | Route (origin) | 1:M |
| Country | Route (destination) | 1:M |
| Customer | Trade | 1:M |
| Supplier | Trade | 1:M |
| Product | Trade | 1:M |
| Route | Trade | 1:M |
| Currency | Trade | 1:M |
| Trade | Invoice | 1:M |
| Invoice | Payment | 1:M |
| Trade | Financial Event | 1:M |
| Trade | Shipment | 1:M |
| Shipment | Operational Event | 1:M |
| Trade | FX Exposure | 1:M |
| Currency | FX Rate | 1:M |
| FX Exposure | Hedge | 1:M |

---

# 9. Expected vs. Actual Architecture

The model intentionally separates expected commercial values from actual business events.

```text
EXPECTED / COMMERCIAL
        │
        ▼
      TRADE
        │
        ├── Expected Revenue
        ├── Expected Procurement Cost
        ├── Expected Operational Cost
        ├── Expected Shipment Date
        └── Expected Payment Date
        │
        ▼
ACTUAL EVENTS
        │
        ├── Invoice
        ├── Payment
        ├── Financial Event
        ├── Shipment
        ├── Operational Event
        └── FX Exposure / Hedge
        │
        ▼
ANALYTICAL CALCULATIONS
        │
        ├── Realized Revenue
        ├── Realized Cost
        ├── Realized Profit
        ├── Margin Variance
        └── Financial Leakage
```
# 10. Derived Analytical Values

The following values are intentionally not stored as independent source records:

- Realized profit
- Profit variance
- Margin percentage
- Leakage amount
- Delay days
- Payment delay
- FX impact
- Hedge effectiveness

These values should be derived from the underlying business events and reference data during the analytical stage.

---

# 11. Data Integrity Rules

The physical schema should enforce the following logical rules:

1. Every foreign key must reference a valid parent record.
2. `currency_id + rate_date` must be unique within FX rates.
3. Every trade must reference a valid customer, supplier, product, route, and currency.
4. Every invoice must reference a valid trade.
5. Every payment must reference a valid invoice.
6. Every shipment must reference a valid trade.
7. Every operational event must reference a valid shipment.
8. Every financial event must reference a valid trade.
9. Every FX exposure must reference a valid trade and currency.
10. Every hedge must reference a valid FX exposure.
11. Origin and destination countries must be valid country records.
12. Derived analytical values should not be duplicated as source values.

---

# 12. Business Question Coverage

The logical model is designed to support the approved analytical questions, including:

- Which suppliers create disproportionate financial leakage relative to their trade volume?
- Which clients are tying up the most working capital?
- Which routes have both high delay and high financial exposure?
- How does expected margin compare with realized margin?
- Where are FX exposures concentrated?
- Which operational events contribute to financial leakage?
- Which trades require management attention?

---

# 13. Logical Model Status

**Status:** Approved for physical schema design.

The logical model has passed review for:

- Entity coverage
- Table grain
- Primary keys
- Foreign keys
- Relationship cardinality
- Expected vs. actual separation
- Attribute placement
- Derived-value treatment
- Business-question coverage

The next stage is the **Physical Data Model / Database Schema**.
