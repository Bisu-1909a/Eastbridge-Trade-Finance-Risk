# Eastbridge Business Discovery Sign-Off

**Project:** Trade Finance Risk & Margin Leakage Intelligence  
**Company:** Eastbridge Global Trading Pvt. Ltd.  
**Sprint:** Sprint 1 — Business Discovery  
**Status:** Ready for Architecture Review

---

# 1. Purpose

This document represents the formal completion checkpoint for
Sprint 1 — Business Discovery.

The purpose of this review is to confirm that the business problem,
stakeholders, requirements, metrics, financial logic, risk framework
and quantitative assumptions are sufficiently defined before the
project enters Data Architecture.

The project will not proceed to synthetic data generation or database
implementation until this checkpoint is passed.

---

# 2. Business Problem

Eastbridge is profitable on paper but experiences cash-flow pressure,
while some trades that appear profitable at approval produce materially
lower realized profitability.

Management needs to understand:

1. Where expected profit disappears.
2. Which financial and operational factors drive the difference.
3. Which customers, suppliers, routes and currencies create
   concentrated exposure.
4. Which active trades require immediate attention.
5. What actions could reduce future financial leakage.

---

# 3. Core Business Question

The project must ultimately answer:

> "We're profitable on paper, but our cash flow is always tight, and
> some trades that should be profitable end up barely breaking even.
> Why, and which deals/partners are causing it?"

---

# 4. Decision Framework

The analytical system follows:

Business Question
        ↓
Analysis
        ↓
Insight
        ↓
Decision
        ↓
Financial Impact

The project is therefore designed as a decision-support system rather
than a reporting-only dashboard.

---

# 5. Stakeholder Coverage

The project explicitly supports five primary stakeholder groups:

## CFO / Senior Finance Leadership

Primary decisions:

- Financial risk prioritization
- Capital allocation
- Management intervention
- Risk appetite

---

## Treasury / Finance

Primary decisions:

- Collection priorities
- Working-capital management
- Financing requirements
- FX hedging priorities

---

## Commercial Manager

Primary decisions:

- Customer payment terms
- Credit limits
- Customer intervention
- Commercial relationship review

---

## Operations Manager

Primary decisions:

- Supplier performance actions
- Route improvement
- Operational issue investigation
- Logistics prioritization

---

## Trade / Procurement Manager

Primary decisions:

- Trade approval
- Trade rejection
- Revised commercial conditions
- Required risk controls

---

# 6. Core Analytical Narrative

Every completed trade is evaluated through the expected-to-realized
profit bridge:

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

The bridge must reconcile.

---

# 7. Financial Reconciliation Rule

The core reconciliation is:

Expected Profit
− FX Impact
− Financing Cost
− Operational Leakage
− Other Leakage
=
Realized Profit

The synthetic model must reconcile within:

**₹1 per trade**

Any material difference outside the tolerance must be investigated.

---

# 8. Leakage Categories

The project explicitly separates:

1. FX Impact
2. Financing Cost
3. Operational Leakage
4. Other Leakage

"Other Leakage" is a controlled residual category and must not be
used to conceal model errors.

Target:

**Normally ≤ 5% of total modeled leakage**

---

# 9. Risk Framework

The project uses three independent risk components:

- Payment Risk
- FX Risk
- Operational Risk

Each component is scored from:

**0–100**

The Overall Risk Index is:

Payment Risk × 40%
+
FX Risk × 30%
+
Operational Risk × 30%

The resulting score is normalized to:

**0–100**

---

# 10. Risk Bands

| Score | Risk Band |
|---:|---|
| 0–30 | Low |
| 31–60 | Moderate |
| 61–80 | High |
| 81–100 | Critical |

These bands are decision-prioritization categories and are not
probabilities of financial loss.

---

# 11. Risk and Exposure Separation

Risk and financial exposure are explicitly treated as separate
dimensions.

Risk answers:

> "How concerning is this trade?"

Exposure answers:

> "How much money is currently exposed?"

The final decision system will therefore use:

**Risk × Exposure**

rather than ranking trades only by risk score.

---

# 12. Core KPI Coverage

The project includes the following KPI groups.

## Profitability

- Expected Gross Profit
- Realized Profit

## Leakage

- Total Leakage
- Leakage Rate
- FX Impact
- Financing Cost
- Operational Leakage
- Other Leakage

## Working Capital

- Average Payment Delay
- DSO
- Outstanding Receivables
- Overdue Receivables

## FX

- Gross FX Exposure
- Unhedged FX Exposure
- FX Impact

## Risk

- Payment Risk Score
- FX Risk Score
- Operational Risk Score
- Overall Risk Index

## Decision Support

- At-Risk Profit
- Financial Exposure
- Risk × Exposure Priority

---

# 13. Critical Business Definitions Confirmed

The project has explicitly defined:

- Expected Profit
- Realized Profit
- Total Leakage
- Leakage Rate
- FX Impact
- Financing Cost
- Operational Leakage
- Other Leakage
- Payment Delay
- Average Payment Delay
- DSO
- FX Exposure
- Unhedged Exposure
- Payment Risk
- FX Risk
- Operational Risk
- Overall Risk Index
- At-Risk Profit
- Financial Exposure

These definitions must remain consistent across SQL, Python and
Power BI.

---

# 14. Business Assumptions Confirmed

The synthetic Eastbridge environment has defined:

- Company scale
- Trade volume
- Trade-size distribution
- Expected margin range
- Customer payment terms
- Supplier terms
- Geographic coverage
- Currency coverage
- FX behavior
- Hedge coverage
- Shipment timelines
- Operational costs
- Financing rate
- Financing day-count convention
- Risk weights
- Risk bands
- Exposure bands
- Reconciliation tolerance
- Synthetic-data behavioral principles

---

# 15. Synthetic Data Governance

The project explicitly prohibits predetermined findings.

The generator must not force conclusions such as:

- One supplier being the worst.
- One country causing the highest leakage.
- FX being the largest leakage source.
- Payment delays being the largest leakage source.
- High-risk trades automatically producing the largest losses.

Instead:

Business assumptions
        ↓
Behavioral rules
        ↓
Synthetic records
        ↓
Validation
        ↓
Analysis
        ↓
Findings

The analytical findings must emerge from the data.

---

# 16. Information Leakage Prevention

Pre-sign and active-trade risk assessments must not use information
that would only become available in the future.

The risk model must not use future:

- Payment outcomes
- Future FX movements
- Future operational events
- Final realized profit

Historical behavioral information may be used where it would have been
available at the assessment point.

---

# 17. Traceability Requirement

Every major analytical output must eventually be traceable through:

Business Question
        ↓
Business Requirement
        ↓
Data Requirement
        ↓
Database Field
        ↓
Calculation
        ↓
Validation
        ↓
Dashboard Metric
        ↓
Business Decision

This traceability is mandatory.

---

# 18. Power BI Decision System

The final dashboard consists of five pages:

## Page 1 — Executive Overview

Answers:

> How much are we losing and where?

---

## Page 2 — Cash-Flow Risk

Answers:

> Why is cash tied up?

---

## Page 3 — FX Exposure

Answers:

> Where are we vulnerable to currency movement?

---

## Page 4 — Trade Risk

Answers:

> Which active trades require attention now?

---

## Page 5 — Recommendations

Answers:

> What should management do and what financial benefit could result?

---

# 19. Success Criteria

The project will be considered successful if it can:

### 1. Explain

Show where expected profit disappears.

### 2. Quantify

Calculate the financial impact of modeled leakage.

### 3. Reconcile

Ensure the expected-to-realized profit bridge balances.

### 4. Prioritize

Identify important risk using both risk and financial exposure.

### 5. Diagnose

Identify meaningful patterns across:

- Customers
- Suppliers
- Countries
- Routes
- Currencies

### 6. Assess

Provide an explainable pre-sign risk assessment.

### 7. Recommend

Translate analytical findings into specific business actions.

### 8. Quantify Recommendations

Estimate potential financial savings from proposed interventions.

### 9. Communicate

Allow a non-technical manager to understand the key problem and
recommended action quickly.

### 10. Demonstrate BA Thinking

Show the complete chain:

Problem
→ Requirements
→ Data
→ Analysis
→ Insight
→ Decision
→ Recommendation
→ Financial Impact

---

# 20. Sprint 1 Quality Gate

The following items have been defined:

| Requirement | Status |
|---|---|
| Company Profile | COMPLETE |
| Business Scenario | COMPLETE |
| Trade Lifecycle | COMPLETE |
| Stakeholder Map | COMPLETE |
| Question → Decision Mapping | COMPLETE |
| Business Objectives | COMPLETE |
| KPI Definitions | COMPLETE |
| Expected Profit Definition | COMPLETE |
| Leakage Taxonomy | COMPLETE |
| Leakage Reconciliation Rule | COMPLETE |
| FX Definitions | COMPLETE |
| Payment Delay Definition | COMPLETE |
| DSO Definition | DEFINED |
| Risk Components | COMPLETE |
| Overall Risk Framework | COMPLETE |
| Risk Bands | COMPLETE |
| Exposure Concept | COMPLETE |
| Exposure Bands | COMPLETE |
| Synthetic Data Principles | COMPLETE |
| Business Assumptions | COMPLETE |
| Success Criteria | COMPLETE |

---

# 21. Outstanding Architecture Decisions

The following items are intentionally deferred to Sprint 2 because
they depend on the final data architecture:

- Exact table structures
- Primary and foreign keys
- Event-level grain
- Historical lookback implementation
- Exact DSO implementation
- Exact FX exposure settlement mechanics
- Detailed operational event structure
- Detailed payment event structure
- SQL implementation
- Python feature engineering implementation
- Power BI data model

These are implementation decisions, not unresolved business
requirements.

---

# 22. Sprint 1 Sign-Off

Sprint 1 — Business Discovery is considered complete when:

- The business problem is clearly defined.
- Stakeholder decisions are identified.
- KPIs have documented definitions.
- Financial leakage has explicit calculations.
- The profit bridge has a reconciliation rule.
- Risk and exposure are separated.
- Synthetic-data assumptions are documented.
- Findings are not predetermined.
- Success criteria are measurable.
- Remaining questions are implementation-level rather than
  business-definition-level.

---

# 23. Next Stage

Following successful sign-off, the project enters:

# Sprint 2 — Data Architecture

The next stage will define:

Business Requirements
        ↓
Data Requirements
        ↓
Business Entities
        ↓
Events
        ↓
Relationships
        ↓
ERD
        ↓
Relational Schema
        ↓
Synthetic Data Design
        ↓
Validation Framework

No production-style data generation should begin before the
architecture is defined.

---

# 24. Final Sprint 1 Principle

The project is not being built to prove a predetermined answer.

It is being built to create a realistic analytical environment in
which the answer can be discovered.

> **We define the business.**
>
> **We define the rules.**
>
> **We generate the evidence.**
>
> **We let the evidence tell us what is wrong.**
>
> **Then we recommend what the business should do.**
