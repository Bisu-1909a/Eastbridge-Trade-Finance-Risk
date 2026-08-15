# Eastbridge KPI & Metric Definitions

**Document Status:** Draft for Project Build  
**Project:** Trade Finance Risk & Margin Leakage Intelligence

---

# 1. Purpose

This document defines the business meaning and calculation logic of
the primary financial, operational and risk metrics used throughout
the Eastbridge analytical system.

The objective is to ensure that the same metric has the same meaning
across:

- SQL
- Python
- Power BI
- Business recommendations

No metric should be implemented before its definition is understood
and documented.

---

# 2. Metric Classification

Metrics are divided into five groups:

1. Profitability
2. Financial Leakage
3. Working Capital / Payment
4. FX Exposure
5. Risk and Financial Exposure

---

# 3. Profitability Metrics

## 3.1 Expected Revenue

### Definition

The revenue Eastbridge expects to receive from a trade at the time
the trade is approved.

### Formula

Expected Revenue
=
Expected Customer Selling Value

### Business Meaning

This represents the original commercial revenue expectation.

---

## 3.2 Expected Trade Cost

### Definition

The total cost expected to be associated with completing a trade at
the time the trade is approved.

This may include:

- Expected procurement cost
- Expected logistics cost
- Expected customs cost
- Other expected trade costs

### Formula

Expected Trade Cost
=
Expected Procurement Cost
+
Expected Operational Cost
+
Other Expected Trade Costs

The exact cost components will be finalized in the business
assumptions document.

---

## 3.3 Expected Gross Profit

### Definition

The expected financial margin at the time a trade is approved,
before subsequently identified leakage effects.

### Formula

Expected Gross Profit
=
Expected Revenue
−
Expected Trade Cost

---

## 3.4 Realized Revenue

### Definition

The revenue actually recognized/settled for the completed trade
within the project's modeled business process.

The exact accounting treatment is intentionally simplified for this
portfolio project and will be documented in the assumptions.

---

## 3.5 Realized Profit

### Definition

The final modeled financial result of a completed trade after
accounting for the explicitly modeled financial and operational
effects.

### Conceptual Formula

Realized Profit
=
Expected Profit
−
FX Impact
−
Financing Cost
−
Operational Leakage
−
Other Leakage

The final implementation must reconcile to this bridge.

---

# 4. Financial Leakage Metrics

## 4.1 Total Leakage

### Definition

The total reduction between expected profit and realized profit that
is explained by the project's modeled leakage components.

### Formula

Total Leakage
=
FX Impact
+
Financing Cost
+
Operational Leakage
+
Other Leakage

---

## 4.2 Leakage Rate

### Definition

The percentage of expected gross profit consumed by modeled
financial leakage.

### Formula

Leakage Rate
=
Total Leakage
÷
Expected Gross Profit
×
100

### Interpretation

A higher value means a greater proportion of expected profit has been
consumed by modeled leakage.

### Guardrail

Trades with zero or negative expected profit require separate
handling and must not create invalid percentage calculations.

---

## 4.3 FX Impact

### Definition

The financial effect caused by foreign-exchange movement between the
defined baseline FX valuation and the applicable settlement outcome.

FX impact is not automatically treated as a loss.

It can be:

- Negative — unfavorable FX movement
- Positive — favorable FX movement
- Zero — no material FX effect

### Calculation Principle

FX Impact
=
Expected FX Outcome
−
Actual FX Outcome

The exact sign convention must be maintained consistently throughout
the project.

---

## 4.4 Financing Cost

### Definition

The modeled cost of additional capital being tied up because cash
remains outstanding for longer than the expected/contractual period.

### Conceptual Formula

Financing Cost
=
Capital Tied Up
×
Annual Financing Rate
×
Delay Duration
÷
Day-Count Basis

The financing rate and day-count convention will be defined in
`business_assumptions.md`.

---

## 4.5 Operational Leakage

### Definition

The unfavorable difference between actual operational costs and
expected operational costs.

### Formula

Operational Leakage
=
Actual Operational Cost
−
Expected Operational Cost

A negative value represents an operational saving.

The project must document how negative variances are treated in the
final leakage bridge.

---

## 4.6 Other Leakage

### Definition

A residual component representing modeled financial differences that
cannot reasonably be assigned to FX, financing or operational
leakage.

### Guardrail

"Other Leakage" must remain intentionally small.

It must never be used as a convenient balancing bucket simply because
the analytical model failed to explain a difference.

### Reconciliation Rule

Any material unexplained difference must be investigated before
"Other" is accepted.

---

# 5. Leakage Bridge

Every completed trade must follow:

Expected Profit
        ↓
FX Impact
        ↓
Financing Cost
        ↓
Operational Leakage
        ↓
Other Leakage
        ↓
Realized Profit

### Reconciliation Formula

Expected Profit
−
FX Impact
−
Financing Cost
−
Operational Leakage
−
Other Leakage
=
Realized Profit

### Quality Requirement

The difference between the calculated bridge result and modeled
realized profit must be within an explicitly defined tolerance.

The tolerance will be defined in `business_assumptions.md`.

Any material variance must be investigated.

---

# 6. Payment & Working-Capital Metrics

## 6.1 Contractual Due Date

### Definition

The date by which the customer is contractually expected to make
payment.

### Formula

Due Date
=
Invoice / Payment Start Date
+
Contractual Payment Terms

The exact starting event will be defined consistently in the data
model.

---

## 6.2 Payment Delay

### Definition

The number of calendar days between the contractual due date and
actual customer payment.

### Formula

Payment Delay
=
Actual Payment Date
−
Contractual Due Date

### Interpretation

Positive:
Customer paid late.

Zero:
Customer paid on time.

Negative:
Customer paid early.

For active unpaid trades, payment delay must not be artificially
calculated using a future or assumed payment date.

---

## 6.3 Average Payment Delay

### Definition

The average payment delay across applicable completed customer
payments.

### Formula

Average Payment Delay
=
Σ Payment Delay
÷
Number of Applicable Payments

The metric should be calculated using completed payment observations
rather than assigning artificial delays to outstanding trades.

---

## 6.4 DSO — Days Sales Outstanding

### Definition

A standard receivables efficiency metric measuring the approximate
number of days required to collect receivables.

DSO is intentionally treated as a separate metric from individual
payment delay.

### Business Purpose

DSO provides a broader working-capital perspective, while payment
delay measures performance against contractual terms.

### Formula

The final DSO implementation will follow the selected standard
receivables methodology and will be documented in the assumptions.

---

## 6.5 Outstanding Receivables

### Definition

Customer amounts that have been invoiced/recognized as receivable
but have not yet been collected as of the analysis date.

---

## 6.6 Overdue Receivables

### Definition

Outstanding customer receivables whose contractual due date has
already passed.

### Formula

Overdue Receivables
=
Outstanding Receivables
where Current Date > Due Date

---

# 7. FX Exposure Metrics

## 7.1 FX Exposure

### Definition

The foreign-currency value of a contractual receivable or payable
whose INR-equivalent value may change before settlement.

FX exposure therefore requires:

- Foreign currency
- Exposure amount
- Exposure direction
- Exposure creation date
- Settlement date or expected settlement date
- Applicable FX rate

---

## 7.2 Gross FX Exposure

### Definition

The absolute foreign-currency value of outstanding exposures before
considering offsets or hedges.

---

## 7.3 Unhedged FX Exposure

### Definition

The portion of FX exposure not covered by the modeled hedge
arrangements.

### Conceptual Formula

Unhedged Exposure
=
Gross Exposure
−
Hedged Exposure

The final treatment of partial hedges will be defined in the
assumptions document.

---

## 7.4 FX Impact by Currency

FX impact should be aggregatable by:

- Currency
- Supplier country
- Customer country
- Trade
- Exposure direction

This allows management to identify concentration rather than only
seeing a single company-wide FX number.

---

# 8. Risk Metrics

## 8.1 Payment Risk Score

### Definition

A 0–100 score representing the modeled payment-related risk of a
trade or counterparty.

The score may consider factors such as:

- Historical payment delay
- Late-payment frequency
- Outstanding exposure
- Payment-term characteristics

The exact weighting will be documented in
`business_assumptions.md`.

---

## 8.2 FX Risk Score

### Definition

A 0–100 score representing the modeled FX-related risk associated
with a trade.

Potential factors include:

- Currency volatility
- Exposure duration
- Exposure size
- Hedge coverage

The final scoring rules will be documented before implementation.

---

## 8.3 Operational Risk Score

### Definition

A 0–100 score representing the modeled operational risk associated
with a trade.

Potential factors include:

- Supplier historical performance
- Route delay history
- Shipment reliability
- Operational cost volatility

---

## 8.4 Overall Risk Index

### Definition

A normalized 0–100 score combining the three explicit risk
components:

- Payment Risk
- FX Risk
- Operational Risk

### Principle

The aggregation must be:

- Transparent
- Explainable
- Rule-based
- Documented
- Reproducible

The exact weighting will be defined in
`business_assumptions.md`.

---

# 9. Risk Bands

The project's initial risk bands are:

| Score | Risk Band |
|---:|---|
| 0–30 | Low |
| 31–60 | Moderate |
| 61–80 | High |
| 81–100 | Critical |

These bands may only be changed through documented project
assumptions.

---

# 10. Financial Exposure Metrics

## 10.1 Trade Financial Exposure

### Definition

The financial amount currently exposed to potential adverse outcomes
for a trade.

Exposure is deliberately kept separate from risk probability or risk
severity.

A trade may therefore have:

- High Risk / Low Exposure
- Low Risk / High Exposure
- High Risk / High Exposure

---

## 10.2 At-Risk Profit

### Definition

The expected profit associated with active trades whose risk band is
Moderate or above.

### Formula

At-Risk Profit
=
Σ Expected Profit
for Active Trades with Risk Band ≥ Moderate

### Guardrail

This metric represents expected profit associated with risk-bearing
active trades.

It must not be interpreted as guaranteed future loss.

---

# 11. Risk × Exposure Priority

Risk and exposure must be analyzed together.

### Conceptual Priority Matrix

| | Low Exposure | Medium Exposure | High Exposure |
|---|---|---|---|
| Low Risk | Monitor | Monitor | Monitor |
| Moderate Risk | Review | Review | Priority |
| High Risk | Review | Priority | High Priority |
| Critical Risk | Priority | High Priority | Immediate Attention |

The exact exposure thresholds will be defined in
`business_assumptions.md`.

---

# 12. Metric Governance Rules

The following rules apply to every metric:

1. Every metric must have one documented business definition.
2. SQL, Python and Power BI must use consistent logic.
3. Sign conventions must remain consistent.
4. Active and completed trades must be distinguished where relevant.
5. Missing values must not be silently converted into zero.
6. Future information must not be used to score active trades.
7. Aggregated metrics must preserve their intended denominator.
8. Financial reconciliation must be validated before visualization.
9. Any material unexplained variance must be investigated.
10. Changes to metric definitions must be documented and versioned.

---

# 13. Metric Traceability

Every major KPI must eventually be traceable through:

Business Question
        ↓
Metric Definition
        ↓
Data Requirement
        ↓
Database Field
        ↓
Calculation
        ↓
Validation
        ↓
Power BI Measure
        ↓
Business Decision

---

# 14. Final KPI Set

The initial executive KPI set is:

### Profitability

- Expected Gross Profit
- Realized Profit

### Leakage

- Total Leakage
- Leakage Rate
- FX Impact
- Financing Cost
- Operational Leakage
- Other Leakage

### Working Capital

- Average Payment Delay
- DSO
- Outstanding Receivables
- Overdue Receivables

### FX

- Gross FX Exposure
- Unhedged FX Exposure
- FX Impact

### Risk

- Payment Risk Score
- FX Risk Score
- Operational Risk Score
- Overall Risk Index

### Decision Support

- At-Risk Profit
- Financial Exposure
- Risk × Exposure Priority
