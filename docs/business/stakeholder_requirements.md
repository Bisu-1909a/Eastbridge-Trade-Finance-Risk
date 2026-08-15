# Eastbridge Stakeholder Requirements

**Document Status:** Draft for Project Build  
**Project:** Trade Finance Risk & Margin Leakage Intelligence

---

# 1. Purpose

This document defines the information and decision-support
requirements of the primary stakeholders involved in Eastbridge's
trade-finance and commercial operations.

The project follows a Business Analyst principle:

> Every major analysis must exist to support a business decision.

Therefore, stakeholder requirements are expressed as:

Stakeholder
    ↓
Business Question
    ↓
Required Analysis
    ↓
Decision
    ↓
KPI / Output
    ↓
Required Data

---

# 2. Stakeholder Groups

The primary stakeholders for this project are:

1. CFO / Senior Finance Leadership
2. Treasury / Finance
3. Commercial Manager
4. Operations Manager
5. Trade / Procurement Manager

---

# 3. CFO / Senior Finance Leadership

## Business Role

The CFO is responsible for understanding the company's overall
financial performance, profitability, capital requirements and
financial risk.

The CFO does not need transaction-level technical detail by default.

The primary requirement is an executive view of:

- Financial leakage
- Profit at risk
- Cash-flow exposure
- Concentration of risk
- Priority areas for intervention

---

## Business Questions

### Q1. How much expected profit is currently at risk?

### Q2. How much leakage has occurred historically?

### Q3. Which risk categories contribute most to financial exposure?

### Q4. Which customers, suppliers, countries or currencies create
the largest financial exposure?

### Q5. Which interventions could produce the greatest financial
benefit?

---

## Required Analysis

The system should provide:

- Expected vs realized profit
- Leakage bridge
- Leakage by risk category
- At-risk profit
- Risk × Exposure analysis
- Counterparty concentration
- Currency exposure
- Historical trends

---

## Decision Supported

The CFO should be able to decide:

- Where management attention should be concentrated
- Whether financial risk is within acceptable limits
- Which business relationships require intervention
- Where capital or treasury resources should be prioritized
- Which recommendations should be escalated to leadership

---

## Primary Outputs

- Expected Profit
- Realized Profit
- Total Leakage
- Leakage Rate
- At-Risk Profit
- Total Financial Exposure
- High/Critical Risk Exposure
- FX Exposure
- Financing Cost
- Operational Leakage

---

# 4. Treasury / Finance

## Business Role

Treasury and Finance are responsible for managing:

- Cash availability
- Receivables
- Payables
- Working capital
- Financing requirements
- Foreign exchange exposure

---

## Business Questions

### Q1. Where is Eastbridge's working capital currently tied up?

### Q2. Which customers consistently pay late?

### Q3. How much additional financing cost is caused by payment delays?

### Q4. Where is FX exposure concentrated?

### Q5. Which exposures are hedged or unhedged?

### Q6. Which currencies create the largest potential financial
impact?

---

## Required Analysis

The system should provide:

- Payment delay analysis
- Customer payment behavior
- Receivable aging
- DSO
- Financing cost
- FX exposure
- FX impact
- Hedge status
- Currency-level exposure

---

## Decision Supported

Treasury / Finance should be able to:

- Prioritize collection efforts
- Review payment terms
- Evaluate financing requirements
- Prioritize FX hedging
- Monitor unhedged exposure
- Identify currencies requiring additional attention

---

## Primary Outputs

- Average Payment Delay
- DSO
- Outstanding Receivables
- Overdue Amount
- Financing Cost
- FX Exposure
- Unhedged FX Exposure
- FX Gain / Loss
- Exposure by Currency

---

# 5. Commercial Manager

## Business Role

The Commercial Manager manages customer relationships, pricing,
commercial terms and customer profitability.

---

## Business Questions

### Q1. Which customers create the greatest working-capital pressure?

### Q2. Which customers consistently pay later than agreed?

### Q3. Are long payment terms creating sufficient commercial value?

### Q4. Which customer relationships create significant financial
exposure despite appearing commercially attractive?

### Q5. Should payment terms or credit limits be reconsidered?

---

## Required Analysis

The system should provide:

- Customer payment behavior
- Payment delay trends
- Customer-level expected vs realized profit
- Customer exposure
- Customer risk
- Payment-term comparison
- Trade frequency and value

---

## Decision Supported

The Commercial Manager should be able to:

- Review customer payment terms
- Reconsider credit limits
- Prioritize collection escalation
- Identify customers requiring commercial intervention
- Evaluate whether high-value customers are also financially
  efficient

---

## Primary Outputs

- Customer Average Payment Delay
- Customer DSO
- Overdue Receivables
- Customer Expected Profit
- Customer Realized Profit
- Customer Leakage
- Customer Risk Score
- Customer Exposure
- Trade Volume

---

# 6. Operations Manager

## Business Role

The Operations Manager is responsible for the physical movement of
goods and the operational execution of international trades.

---

## Business Questions

### Q1. Which suppliers create the most operational delays?

### Q2. Which routes have the highest delay frequency?

### Q3. Where are customs or documentation problems concentrated?

### Q4. How much financial leakage is associated with operational
issues?

### Q5. Which routes or suppliers should receive operational
improvement attention?

---

## Required Analysis

The system should provide:

- Shipment performance
- Transit delay
- Supplier performance
- Route performance
- Operational event frequency
- Expected vs actual operational cost
- Operational leakage
- Delay trends

---

## Decision Supported

The Operations Manager should be able to:

- Review supplier performance
- Investigate problematic routes
- Improve logistics planning
- Address documentation issues
- Prioritize operational improvement initiatives

---

## Primary Outputs

- Average Shipment Delay
- Delay Rate
- Operational Leakage
- Expected Operational Cost
- Actual Operational Cost
- Supplier Performance
- Route Performance
- Operational Risk Score

---

# 7. Trade / Procurement Manager

## Business Role

The Trade / Procurement Manager evaluates and approves new trade
opportunities and manages supplier relationships.

This stakeholder is particularly important because the project
eventually needs to support **pre-sign decision-making**.

---

## Business Questions

### Q1. Should this new trade be approved?

### Q2. What financial risk exists before the trade is signed?

### Q3. Which components create the highest risk?

### Q4. Is the trade's expected profit sufficient relative to its
financial exposure?

### Q5. What conditions should be attached to approval?

---

## Required Analysis

The system should evaluate:

- Expected profit
- Trade size
- Customer payment history
- Supplier performance history
- Route characteristics
- Currency exposure
- Hedge status
- Payment risk
- FX risk
- Operational risk
- Overall Risk Index
- Risk × Exposure priority

---

## Decision Supported

The Trade / Procurement Manager should be able to:

- Approve the trade
- Reject the trade
- Request revised commercial terms
- Require stronger payment conditions
- Require FX hedging
- Require operational safeguards
- Escalate high-exposure trades

---

## Primary Outputs

- Expected Profit
- Payment Risk Score
- FX Risk Score
- Operational Risk Score
- Overall Risk Index
- Financial Exposure
- Risk × Exposure Priority
- Recommended Conditions

---

# 8. Question → Decision Matrix

| Stakeholder | Business Question | Analysis | Decision |
|---|---|---|---|
| CFO | How much profit is at risk? | Expected vs realized profit + leakage bridge | Capital/risk prioritization |
| CFO | Where is exposure concentrated? | Risk × Exposure | Management intervention |
| Treasury | Where is cash tied up? | Receivables + payment delay | Collection priority |
| Treasury | Where is FX exposure concentrated? | Currency/exposure analysis | Hedging priority |
| Commercial | Which customers create pressure? | Payment behavior + exposure | Terms/credit review |
| Operations | Which routes cause leakage? | Delay + operational cost analysis | Route/supplier action |
| Procurement | Should this trade be approved? | Pre-sign risk assessment | Go / no-go / conditions |

---

# 9. Cross-Stakeholder Decision Hierarchy

The system should support decisions at three levels.

## Level 1 — Executive

Question:

> "Where should management focus?"

Outputs:

- Total leakage
- At-risk profit
- Exposure
- Risk concentration
- Priority recommendations

---

## Level 2 — Functional

Question:

> "What operational or financial action should my team take?"

Outputs:

- Customer risk
- Supplier performance
- Route performance
- FX exposure
- Payment behavior
- Financing cost

---

## Level 3 — Trade

Question:

> "What should we do about this specific trade?"

Outputs:

- Expected profit
- Risk components
- Exposure
- Risk band
- Required conditions

---

# 10. Requirement Prioritization

Requirements are classified using three levels.

## Must Have

These are essential to the project's core business objective.

- Expected vs realized profit
- Leakage bridge
- Payment analysis
- FX exposure
- Operational leakage
- Risk scoring
- Risk × Exposure
- Executive recommendations

---

## Should Have

These improve decision quality but are not fundamental to the
project's existence.

- Customer payment history trends
- Supplier performance trends
- Route comparisons
- Currency concentration
- Historical risk trends

---

## Could Have

These may improve usability but are intentionally lower priority.

- Advanced drill-through experiences
- Additional segmentation
- Additional visualization variations
- Extended scenario comparisons

---

# 11. Decision-Support Principle

The final Power BI system must avoid becoming a collection of
unconnected charts.

Every major page should answer:

> What question does this page answer?

and:

> What decision can the stakeholder make from it?

---

# 12. Traceability Requirement

Each major dashboard metric must eventually be traceable through:

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
Dashboard Metric
    ↓
Decision

This traceability is a core Business Analyst quality requirement.

---

# 13. Requirement Success Condition

The project succeeds from a stakeholder perspective when a manager
can move from:

"What happened?"

to:

"Why did it happen?"

to:

"Where is the exposure?"

to:

"What should we do?"

without requiring technical knowledge of SQL or Python.

