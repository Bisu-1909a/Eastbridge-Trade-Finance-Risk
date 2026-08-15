# Eastbridge Data Requirements

**Project:** Trade Finance Risk & Margin Leakage Intelligence  
**Sprint:** Sprint 2 — Data Architecture  
**Mission:** 3.1 — Business Requirements → Data Requirements  
**Status:** Architecture Draft

---

# 1. Purpose

This document translates the approved business requirements from
Sprint 1 into data requirements.

The objective is to determine what information Eastbridge would need
to capture and maintain in order to answer the project's business
questions.

This document does not define the final database schema.

The sequence is:

Business Question
        ↓
Decision
        ↓
Information Required
        ↓
Data Requirement
        ↓
Data Entity / Event
        ↓
Database Schema

---

# 2. Data Architecture Principle

The data model must represent real business events rather than being
designed around dashboard charts.

The system should preserve:

- Who
- What
- When
- Where
- How much
- Under what terms
- What was expected
- What actually happened
- What financial impact resulted

This allows the same underlying data to support SQL analysis,
Python risk scoring and Power BI.

---

# 3. Requirement Categories

Data requirements are grouped into:

1. Master Data
2. Trade Data
3. Commercial Terms
4. Payment Data
5. Shipment Data
6. Operational Cost Data
7. FX Data
8. Hedge Data
9. Risk History Data
10. Reference Data

---

# 4. Master Data Requirements

## 4.1 Customer

The system must identify every customer participating in Eastbridge
trades.

### Required information

- Customer ID
- Customer name
- Customer country
- Customer region
- Customer segment
- Customer status
- Default currency
- Customer risk/profile classification

### Business Questions Supported

- Which customers create working-capital pressure?
- Which customers have poor payment behavior?
- Which customers generate the largest exposure?
- Which customers contribute to leakage?

---

## 4.2 Supplier

The system must identify every supplier involved in Eastbridge
trades.

### Required information

- Supplier ID
- Supplier name
- Supplier country
- Supplier region
- Supplier status
- Primary currency
- Supplier profile/classification

### Business Questions Supported

- Which suppliers create operational leakage?
- Which suppliers experience frequent delays?
- Which suppliers create financial exposure?

---

## 4.3 Country

Country information must be standardized rather than repeatedly
stored as uncontrolled text.

### Required information

- Country ID
- Country name
- Region
- Country classification

### Purpose

Supports:

- Supplier-country analysis
- Customer-country analysis
- Route analysis
- Geographic concentration analysis

---

## 4.4 Currency

Each currency must be represented consistently.

### Required information

- Currency code
- Currency name
- Base/foreign classification

### Purpose

Supports:

- FX exposure
- FX impact
- Currency concentration
- FX risk

---

# 5. Trade Data Requirements

## 5.1 Trade

The trade is the central commercial business object.

Every trade must have a unique identifier.

### Required information

- Trade ID
- Customer ID
- Supplier ID
- Route ID
- Trade status
- Trade type
- Product/category
- Trade creation date
- Contract/sign date
- Expected completion date
- Transaction currency
- Expected revenue
- Expected procurement cost
- Expected operational cost
- Expected gross profit

### Business Questions Supported

- How profitable was the trade expected to be?
- Which trades are currently active?
- What financial exposure exists?
- What happened between approval and settlement?

---

# 6. Commercial Terms Requirements

Commercial terms must be stored separately from the trade's actual
events where appropriate.

### Required information

- Payment term
- Payment term days
- Customer payment conditions
- Supplier payment conditions
- Advance-payment percentage
- Credit/collection conditions
- Contractual currency
- Agreed commercial value

### Business Questions Supported

- Are long payment terms creating working-capital pressure?
- Which customers operate under high-credit terms?
- How do commercial terms influence risk?

---

# 7. Payment Data Requirements

Payment must be modeled as an independent business event.

A trade may have:

- One payment
- Multiple payments
- Partial payments
- Outstanding payment

Therefore payment information must not simply be stored as a single
date on the trade record.

### Required information

- Payment ID
- Trade ID
- Payment type
- Invoice/reference ID
- Payment due date
- Actual payment date
- Payment amount
- Payment currency
- Payment status
- Outstanding amount
- Payment method/reference where relevant

### Derived Information

The analytical layer should calculate:

Payment Delay
=
Actual Payment Date
−
Contractual Due Date

### Business Questions Supported

- Which customers pay late?
- How much is overdue?
- Where is cash tied up?
- What financing cost is associated with delays?

---

# 8. Invoice / Receivable Requirements

Receivables must be distinguishable from payment events.

### Required information

- Invoice ID
- Trade ID
- Customer ID
- Invoice date
- Due date
- Invoice amount
- Currency
- Outstanding amount
- Invoice status

### Purpose

Supports:

- DSO
- Receivables aging
- Outstanding receivables
- Overdue receivables
- Payment behavior

---

# 9. Shipment Data Requirements

Shipment is an independent business process.

### Required information

- Shipment ID
- Trade ID
- Route ID
- Shipment start date
- Expected arrival date
- Actual arrival date
- Shipment status
- Transport mode
- Carrier
- Shipment reference

### Derived Information

Shipment Delay
=
Actual Arrival Date
−
Expected Arrival Date

### Business Questions Supported

- Which routes experience delays?
- Which suppliers create operational problems?
- Where is operational leakage concentrated?

---

# 10. Operational Event Requirements

Shipment dates alone may not explain why operational leakage occurs.

The system should therefore be capable of representing significant
operational events.

### Possible event types

- Supplier readiness delay
- Documentation issue
- Customs delay
- Port delay
- Carrier delay
- Inspection delay
- Other operational disruption

### Required information

- Operational Event ID
- Trade ID / Shipment ID
- Event type
- Event date
- Event status
- Expected impact
- Actual impact
- Event description/category

### Purpose

Allows operational analysis beyond simply comparing two dates.

---

# 11. Operational Cost Requirements

Expected and actual operational costs must be separately captured.

### Expected cost information

- Expected freight
- Expected customs
- Expected handling
- Expected documentation cost
- Other expected operational costs

### Actual cost information

- Actual freight
- Actual customs
- Actual handling
- Actual documentation cost
- Other actual operational costs

### Derived Metric

Operational Leakage
=
Actual Operational Cost
−
Expected Operational Cost

---

# 12. FX Exposure Requirements

FX exposure must be represented as a business object/event rather
than inferred only from a currency field.

### Required information

- FX Exposure ID
- Trade ID
- Exposure type
- Exposure direction
- Currency
- Foreign-currency amount
- Exposure creation date
- Expected settlement date
- Actual settlement date
- Baseline FX rate
- Settlement FX rate
- Hedge status
- Hedged amount

### Exposure Directions

- Receivable
- Payable

### Business Questions Supported

- Where is FX exposure concentrated?
- Which currencies create the greatest exposure?
- Which exposures are unhedged?
- What FX impact occurred?

---

# 13. FX Rate Requirements

FX rates should be stored separately from individual trades.

### Required information

- FX Rate ID
- Currency
- Rate date
- INR conversion rate
- Rate source/type

### Purpose

Allows multiple trades to reference consistent currency rates.

This also supports temporal FX analysis.

---

# 14. Hedge Requirements

Hedging must be represented separately from FX exposure.

### Required information

- Hedge ID
- Trade ID / FX Exposure ID
- Hedge instrument/type
- Hedge start date
- Hedge maturity date
- Hedged currency
- Hedged amount
- Hedge rate
- Hedge status

### Purpose

Supports:

- Gross FX exposure
- Hedged exposure
- Unhedged exposure
- FX risk assessment

---

# 15. Risk History Requirements

Pre-sign risk assessment requires historical information.

The system must therefore preserve sufficient historical business
behavior to calculate risk features.

### Customer historical features

Potentially derived from:

- Previous payment delays
- Late-payment frequency
- Historical outstanding exposure
- Historical trade volume

### Supplier historical features

Potentially derived from:

- Shipment delays
- Operational events
- Cost variance
- Historical trade performance

### Route historical features

Potentially derived from:

- Historical transit duration
- Delay frequency
- Operational disruptions

### Currency historical features

Potentially derived from:

- Historical FX movement
- Volatility
- Exposure duration

Important:

These features should be calculated from historical events rather
than manually stored as arbitrary risk values unless there is a clear
business reason.

---

# 16. Risk Assessment Requirements

The final risk score must be explainable.

The system should be able to identify the underlying inputs used for:

- Payment Risk
- FX Risk
- Operational Risk
- Overall Risk Index

The data architecture must therefore preserve the underlying
observations rather than only storing the final score.

---

# 17. Route Requirements

A route represents the movement relationship between an origin and
destination.

### Required information

- Route ID
- Origin country
- Destination country
- Typical transit duration
- Transport mode
- Route status

### Purpose

Supports:

- Route performance
- Shipment delays
- Operational risk
- Geographic analysis

---

# 18. Trade Lifecycle Requirements

The data architecture must support the following lifecycle:

Trade Identified
      ↓
Trade Approved/Signed
      ↓
Supplier Commitment
      ↓
Shipment Initiated
      ↓
Goods Arrive
      ↓
Invoice / Receivable
      ↓
Customer Payment
      ↓
FX Settlement
      ↓
Trade Completed

Not every trade will necessarily contain every event at the same
time.

Active trades may stop at an intermediate stage.

---

# 19. Expected vs Actual Data Requirement

A core project requirement is the ability to distinguish:

### Expected

What management believed would happen when the trade was approved.

from:

### Actual

What eventually happened.

This applies to:

- Revenue
- Procurement cost
- Operational cost
- Payment timing
- FX outcome
- Shipment timing

The architecture must preserve both concepts.

---

# 20. Active vs Completed Trade Requirement

The system must distinguish:

### Active Trade

A trade whose lifecycle has not yet reached completion.

### Completed Trade

A trade for which the required financial outcomes are known and the
profit bridge can be reconciled.

This distinction is essential because active trades cannot use future
outcomes for pre-sign or current-risk assessment.

---

# 21. Data Grain Requirements

Before designing physical tables, the grain of each business object
must be explicitly defined.

Examples:

### Trade

One record represents one commercial trade.

### Payment

One record represents one payment event.

### Shipment

One record represents one shipment event.

### FX Rate

One record represents one currency's rate for one date.

### Operational Event

One record represents one operational event.

### FX Exposure

One record represents one defined FX exposure.

The exact grain will be finalized during ERD design.

---

# 22. Historical Data Requirement

The system must contain enough historical information to calculate
behavior-based risk features.

The synthetic environment should support:

- Customer payment history
- Supplier performance history
- Route performance history
- Currency behavior
- Trade-level historical outcomes

Historical information must be timestamped so that only information
available before a decision point can be used for pre-sign risk
assessment.

---

# 23. Data Quality Requirements

The future database must support validation of:

### Referential Integrity

Every foreign-key relationship must point to a valid record.

### Temporal Integrity

Business events must occur in logical chronological order.

### Financial Integrity

Expected and actual values must reconcile.

### Currency Integrity

Currency and FX-rate relationships must be valid.

### Completeness

Required fields must exist for the relevant lifecycle stage.

### Uniqueness

Business identifiers must not contain unintended duplicates.

---

# 24. Traceability Matrix

| Business Requirement | Information Required | Primary Data Area |
|---|---|---|
| Explain expected vs realized profit | Expected and actual financial values | Trade / Cost / FX |
| Explain payment delays | Due dates + payment events | Invoice / Payment |
| Calculate DSO | Receivables + sales/collection timing | Invoice / Payment |
| Explain operational leakage | Expected + actual operational cost | Trade / Shipment / Cost |
| Analyze FX impact | Exposure + FX rates + settlement | FX Exposure / FX Rate |
| Analyze customer risk | Customer history + payments | Customer / Payment / Trade |
| Analyze supplier risk | Supplier history + shipments | Supplier / Shipment |
| Analyze route risk | Route + shipment history | Route / Shipment |
| Assess new trades | Historical behavior + proposed trade | Multiple domains |
| Prioritize exposure | Risk + financial value | Trade / Exposure |
| Recommend actions | All relevant financial drivers | Integrated model |

---

# 25. Minimum Information Set

The architecture must eventually be capable of representing at least:

### Master Data

- Customer
- Supplier
- Country
- Currency
- Route

### Commercial Data

- Trade
- Commercial Terms
- Product/Category

### Financial Events

- Invoice / Receivable
- Payment
- Operational Cost
- FX Exposure
- FX Rate
- Hedge

### Operational Events

- Shipment
- Operational Event

### Analytical Information

- Historical behavior
- Risk assessment inputs
- Risk score
- Financial exposure

---

# 26. Architecture Principle

The final database must not be designed around Power BI visuals.

Instead:

Business Requirements
        ↓
Data Requirements
        ↓
Business Entities
        ↓
Business Events
        ↓
Relationships
        ↓
Relational Model
        ↓
Analysis
        ↓
Dashboard

The dashboard is the final consumer of the model, not the reason the
model exists.

---

# 27. Next Architecture Stage

The next mission is to convert these data requirements into a
conceptual business model.

We will identify:

- Entities
- Events
- Relationships
- Cardinality
- Ownership
- Business grain

Only after that will we design the physical SQL schema.

---

# 28. Mission 3.1 Completion Criteria

Mission 3.1 is complete when:

- Every major business question has corresponding data requirements.
- Expected and actual outcomes can be represented.
- Payment events are separated from trades.
- Shipment events are separated from trades.
- FX exposure is explicitly represented.
- FX rates are separated from exposures.
- Hedging is separately represented.
- Historical behavior can be reconstructed.
- Active and completed trades can be distinguished.
- Risk scores can be explained from underlying observations.
- Data quality requirements are identified.
- The requirements can be translated into a conceptual ERD.

---

# Final Principle

We are not asking:

> "What tables should we create?"

We are asking:

> "What must Eastbridge know about its business so that every
important decision can be answered with evidence?"

Only after answering that question do we design the tables.
