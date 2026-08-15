# Conceptual Data Model
### Eastbridge Trade Co. — Trade Finance Risk & Margin Leakage Intelligence

---

## 1. Core Architectural Decision: Objects vs Events

**Business objects** — things that *exist*: Customer, Supplier, Product, Country, Currency, Route, Trade
**Business events** — things that *happen*: Invoice, Payment, Shipment, Operational Event, FX Exposure, Hedge, FX Rate Observation

A customer exists once; it can have hundreds of payments over time. Objects and events are modeled separately so the grain of every table stays clean.

---

## 2. Conceptual Model (first view)

```
                         ┌─────────────┐
                         │   COUNTRY   │
                         └──────┬──────┘
                                │
                 ┌──────────────┴──────────────┐
                 │                             │
          ┌──────▼──────┐               ┌──────▼──────┐
          │  CUSTOMER   │               │  SUPPLIER   │
          └──────┬──────┘               └──────┬──────┘
                 │                             │
                 └──────────┐       ┌──────────┘
                            ▼       ▼
                         ┌────────────┐
                         │   TRADE    │
                         └─────┬──────┘
                               │
              ┌────────────────┼─────────────────┐
              │                │                 │
              ▼                ▼                 ▼
         ┌─────────┐      ┌──────────┐     ┌──────────────┐
         │ INVOICE │      │ SHIPMENT │     │ FX EXPOSURE  │
         └────┬────┘      └────┬─────┘     └──────┬───────┘
              │                │                  │
              ▼                ▼                  ├─────────────┐
         ┌─────────┐   ┌─────────────────┐       ▼             ▼
         │ PAYMENT │   │ OPERATIONAL     │    ┌───────┐     ┌───────┐
         │         │   │ EVENT           │    │  FX   │     │ HEDGE │
         └─────────┘   └─────────────────┘    │ RATE  │     └───────┘
                                              └───────┘
```

Refinement: FX Rate is not owned by FX Exposure — it's a reference time-series the exposure looks up by currency + date.

```
Currency ──< FX Rate            FX Exposure ──< Hedge
```

---

## 3. Entity & Event Definitions

### CUSTOMER
- **Meaning:** A business entity that purchases goods/services from Eastbridge
- **Grain:** One record = one customer · **Key:** `customer_id`
- **Relationship:** `Customer 1 ──< Trade`

### SUPPLIER
- **Meaning:** A business entity that supplies goods to Eastbridge
- **Grain:** One record = one supplier · **Key:** `supplier_id`
- **Relationship:** `Supplier 1 ──< Trade`

### COUNTRY
- **Meaning:** Standardized geographic reference (prevents "India" / "IND" / "india" free-text inconsistency)
- **Grain:** One record = one country
- **Relationship:** Linked to Customers, Suppliers, Routes

### CURRENCY
- **Meaning:** A currency used in commercial/financial transactions (INR, USD, EUR, AED, GBP)
- **Grain:** One record = one currency — never redefined inline inside every transaction

### PRODUCT
- **Meaning:** What Eastbridge actually trades (Industrial Components, Electrical Equipment, Packaging Materials, Machinery Parts, Specialty Chemicals — portfolio finalized later)
- **Grain:** One record = one product/category · **Relationship:** `Product 1 ──< Trade`

### ROUTE
- **Meaning:** A standardized commercial/logistics corridor (e.g. Vietnam → Mumbai, Germany → Mumbai)
- **Grain:** One record = one route, reused across many trades · **Relationship:** `Route 1 ──< Trade`

### TRADE (central entity)
- **Meaning:** One commercial transaction approved/signed by Eastbridge — connects Customer, Supplier, Product, Route, Currency, and commercial terms
- **Grain:** One record = one trade (e.g. `TRD-000184`)
- **Critical rule:** Trade does **not** contain `payment_date`, `shipment_date`, `fx_rate`, or delay fields directly. One trade can have 2 invoices, 3 payments, 2 shipments, 4 operational events, 2 FX exposures, 1 hedge — pushing those into Trade creates repeating/multi-valued fields and breaks the analytical model.

### INVOICE (event)
- **Meaning:** A receivable generated from a trade
- **Grain:** One record = one invoice · **Relationship:** `Trade 1 ──< Invoice`

### PAYMENT (event)
- **Meaning:** An actual financial settlement event
- **Grain:** One record = one payment · **Relationship:** `Invoice 1 ──< Payment` (an invoice can be settled across multiple partial payments — e.g. ₹1Cr invoice paid as ₹40L + ₹30L + ₹30L)

### SHIPMENT (event)
- **Meaning:** The physical/logistics movement tied to a trade
- **Grain:** One record = one shipment · **Relationship:** `Trade 1 ──< Shipment` (a trade may be split across multiple shipments)

### OPERATIONAL EVENT (event)
- **Meaning:** Something that happens during execution — customs delay, documentation issue, port congestion, carrier delay, inspection delay, supplier readiness delay
- **Grain:** One record = one operational event · **Relationship:** `Shipment 1 ──< Operational Event`
- This gives far richer analysis than a flat `expected_arrival` / `actual_arrival` pair

### FX EXPOSURE (event) — one of the most important objects in the model
- **Meaning:** How much foreign-currency financial value Eastbridge is exposed to, in which direction, over what period. Example: Trade TRD-001, USD receivable, $500,000, exposure created 10 June, expected settlement 25 July
- **Grain:** One record = one identifiable exposure · **Relationship:** `Trade 1 ──< FX Exposure`
- **Why separate from Trade:** storing `trade.currency` alone can't answer who owes whom, how much, when exposure begins/ends, or whether it's hedged

### FX RATE OBSERVATION (reference/event)
- **Meaning:** A currency's exchange rate on a specific date (e.g. `USD | 2026-01-10 | ₹83.20`)
- **Grain:** One record = one currency/date observation · **Relationship:** `Currency 1 ──< FX Rate`
- Referenced by exposures via currency + date, not owned by them

### HEDGE (event)
- **Meaning:** A financial instrument/action used to offset FX exposure
- **Grain:** One record = one hedge arrangement · **Relationship:** `FX Exposure 1 ──< Hedge` (an exposure can be hedged in stages)

---

## 4. Full Relationship Map

```
                       COUNTRY
                      /       \
                     ▼         ▼
               CUSTOMER      SUPPLIER
                   │             │
                   └──────┬──────┘
                          ▼
                       TRADE
                    /    │    \
                   ▼     ▼     ▼
             PRODUCT   ROUTE   INVOICE
                               │
                               ▼
                            PAYMENT

TRADE ──────────────► SHIPMENT ──────► OPERATIONAL EVENT
TRADE ──────────────► FX EXPOSURE ──┬─► HEDGE
                                     └─  (references) ─► FX RATE ◄── CURRENCY
```

---

## 5. Cardinality Summary

| Relationship | Cardinality |
|---|---|
| Country → Customer | 1:M |
| Country → Supplier | 1:M |
| Customer → Trade | 1:M |
| Supplier → Trade | 1:M |
| Product → Trade | 1:M |
| Route → Trade | 1:M |
| Currency → Trade | 1:M |
| Trade → Invoice | 1:M |
| Invoice → Payment | 1:M |
| Trade → Shipment | 1:M |
| Shipment → Operational Event | 1:M |
| Trade → FX Exposure | 1:M |
| FX Exposure → Hedge | 1:M |
| Currency → FX Rate | 1:M |

---

## 6. The Grain Rule

Every table must have a grain statement that can be said in one sentence. If we can't explain what one row means, we don't build the table.

| Table | Grain |
|---|---|
| Customer | one row per customer |
| Trade | one row per trade |
| Invoice | one row per invoice |
| Payment | one row per payment event |
| Shipment | one row per shipment |
| Operational Event | one row per operational event |
| FX Exposure | one row per exposure |
| Hedge | one row per hedge arrangement |
| FX Rate | one row per currency/date observation |

---

## 7. Expected vs Actual

| Expected (belief at trade approval) | Actual (what happened) |
|---|---|
| Expected revenue | Actual revenue |
| Expected procurement cost | Actual procurement cost |
| Expected operational cost | Actual operational cost |
| Expected shipment date | Actual arrival |
| Expected payment date | Actual payment |
| Expected FX outcome | Actual settlement FX |

This distinction is what makes the leakage bridge possible — and it lives on the Trade record (expected) plus the event tables (actual), not duplicated in both places.

---

## 8. Why No `realized_profit` Table (yet)

Creating a standalone `realized_profit` table now would be premature and risks circularity:
```
Realized Profit → Leakage → Realized Profit   ✗ circular
```
Instead, realized profit is **derived**, not stored:
```
Expected Financials + Actual Financial Events → Financial Calculations → Realized Profit → Leakage Bridge   ✓
```

---

## 9. What We Discovered

The original concept (`Supplier → Client → Trade`) has grown into 12 conceptual objects, organized as:

```
MASTER DATA        COMMERCIAL     FINANCIAL EVENTS      OPERATIONAL EVENTS
├── Customer        └── Trade      ├── Invoice            ├── Shipment
├── Supplier                       ├── Payment             └── Operational Event
├── Product                        ├── FX Exposure
├── Country                        ├── Hedge
├── Currency                       └── FX Rate
└── Route
```

**Kill-critic check:** Could this be simplified by dropping Invoice, Operational Event, FX Exposure, or Hedge? Yes — but that weakens the business story. The design principle isn't "smallest possible database," it's **the smallest realistic model capable of answering the approved business questions** from Sprint 1.

---

## 10. Where This Sits in the Sequence

```
Sprint 1 — Business Discovery
        ↓
Sprint 2 — Data Requirements
        ↓
🔥 Conceptual Data Model (this document) 🔥
        ↓
Next: Logical ERD → Physical Schema → SQL → Synthetic Data
```

No SQL yet, deliberately — so that when `CREATE TABLE trade (...)` is finally written, every column has a known reason for existing.
