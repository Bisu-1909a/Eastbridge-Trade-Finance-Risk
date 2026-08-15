# Eastbridge Business Assumptions

**Document Status:** Version 1.0 — Sprint 1 Business Lock  
**Project:** Trade Finance Risk & Margin Leakage Intelligence  
**Company:** Eastbridge Global Trading Pvt. Ltd.  
**Base Currency:** INR  
**Analysis Period:** January 2024 – December 2026

---

# 1. Purpose

This document defines the quantitative and behavioral assumptions
used to construct the fictional Eastbridge business environment.

These assumptions are used for:

- Synthetic data generation
- Financial calculations
- Risk scoring
- Exposure classification
- Validation
- Power BI analysis

The assumptions define how the business behaves.

They do NOT define the final analytical findings.

For example, the project will not assume in advance that FX, payment
delays or operational problems are the largest source of leakage.

Those outcomes must emerge from the generated data.

---

# 2. Business Scale

Eastbridge is modeled as a mid-sized B2B international trading
company.

The synthetic business environment will represent approximately:

- 1,500–2,000 completed and active trade records
- 80–120 customers
- 30–50 suppliers
- 25–40 international trade routes
- 4 primary foreign currencies
- 36 months of historical activity

The final generated dataset may vary slightly within these ranges
where necessary to preserve realistic relationships between entities.

---

# 3. Trade Volume

Eastbridge operates throughout the year.

Trade frequency is not perfectly uniform.

The generator should allow realistic variation caused by:

- Seasonal demand
- Product category
- Customer behavior
- Supplier relationships
- Regional demand
- Business cycles

The dataset should contain enough observations to support:

- Customer comparisons
- Supplier comparisons
- Country analysis
- Currency analysis
- Monthly trends
- Risk segmentation

---

# 4. Trade Size Distribution

Trade values should follow a right-skewed commercial distribution.

The majority of transactions should be small-to-medium sized, while
a smaller number of large transactions should represent a significant
portion of total trade value.

Indicative trade-value bands:

| Trade Category | Approximate Value |
|---|---:|
| Small | ₹0.5M–₹2M |
| Medium | ₹2M–₹10M |
| Large | ₹10M–₹30M |
| Strategic | ₹30M–₹75M |

These are generation ranges rather than guaranteed proportions.

The generator must avoid producing a perfectly uniform distribution.

---

# 5. Expected Profit Margin

Eastbridge operates with relatively thin B2B trading margins.

Expected gross profit margin should generally fall within:

**5%–18% of expected revenue**

The majority of trades should fall toward the middle of this range.

Very high-margin trades should be uncommon.

Negative expected-profit trades should be rare because the business
would normally reject clearly uneconomic transactions before signing.

However, a small number of low-margin trades may exist because of:

- Competitive pricing
- Strategic customer relationships
- Large-volume contracts
- Commercial concessions

---

# 6. Customer Payment Terms

Customer payment terms may include:

- Advance / partial advance
- 15 days
- 30 days
- 45 days
- 60 days
- 90 days

The most common terms should be approximately:

**30–60 days**

Longer terms should be less common.

Customer payment behavior must vary by customer persona.

Some customers should consistently pay close to their contractual
terms.

Others should demonstrate:

- Occasional delays
- Persistent delays
- High late-payment frequency

However, the generator must avoid making any single customer
universally bad.

---

# 7. Payment Delay Behavior

Payment delay should be modeled as a behavioral distribution rather
than a completely random number.

Customer personas may include:

### Reliable Customer

Typically pays:

- Early
- On time
- Or only slightly late

### Normal Commercial Customer

Typically pays:

- Around the contractual due date
- With occasional moderate delays

### Slow-Paying Customer

Frequently pays:

- 10–30 days late

### High-Pressure Customer

May experience:

- Repeated substantial delays
- Larger overdue balances
- Greater working-capital pressure

The exact percentage of each persona must not be designed to force
a predetermined business conclusion.

---

# 8. Supplier Payment Terms

Supplier payment structures may include:

- Advance payment
- Partial advance
- Payment against shipping documents
- 30 days
- 45 days
- 60 days

Terms should vary based on:

- Supplier relationship
- Country
- Supplier maturity
- Negotiated commercial conditions

---

# 9. Supplier Behavioral Profiles

Suppliers should vary across:

- Shipment reliability
- Operational consistency
- Documentation quality
- Transit performance
- Cost stability

Possible supplier personas include:

### High Reliability

Low delay frequency and stable operating performance.

### Normal Reliability

Occasional delays and moderate variability.

### Inconsistent Supplier

Higher delay frequency and greater operational variability.

No supplier should be hard-coded as "the worst supplier."

The final ranking must emerge from the generated data.

---

# 10. Geographic Assumptions

Primary supplier countries:

- China
- Singapore
- Germany
- United Kingdom
- United States

Primary customer markets:

- India
- United Arab Emirates
- Singapore
- Selected Southeast Asian markets

Country-level behavior should not automatically determine financial
performance.

Country may influence:

- Transit time
- Currency
- Route complexity
- Documentation requirements
- Operational variability

But these effects should be probabilistic rather than deterministic.

---

# 11. Currency Assumptions

Eastbridge's reporting currency is:

**INR**

Primary transaction currencies:

| Currency | Typical Usage |
|---|---|
| USD | Major international supplier and customer transactions |
| EUR | European suppliers |
| GBP | UK suppliers |
| CNY | Chinese supplier transactions |

USD should be the dominant foreign currency.

However, the generator should contain sufficient EUR, GBP and CNY
transactions to make currency-level analysis meaningful.

---

# 12. FX Exposure

FX exposure exists when Eastbridge has a foreign-currency contractual
amount whose INR-equivalent value may change before settlement.

Each FX exposure should contain, where applicable:

- Currency
- Foreign-currency amount
- Exposure direction
- Exposure creation date
- Expected settlement date
- Actual settlement date
- Baseline FX rate
- Settlement FX rate
- Hedge status

Exposure direction must distinguish between:

- Foreign-currency receivable
- Foreign-currency payable

This is essential because the same FX movement can affect different
exposure directions differently.

---

# 13. FX Modeling Principle

FX rates must not be generated as independent random values for every
trade.

The generator should create a plausible time series for each
currency.

Trade-level FX rates should then be derived from the relevant
currency/date relationship.

This creates temporal consistency.

The project does not attempt to reproduce historical market FX rates
exactly.

The purpose is to create realistic analytical behavior.

---

# 14. FX Volatility

Each currency should have a different modeled volatility profile.

The generator should allow:

- Normal periods
- Moderate currency movements
- Occasional larger movements

Extreme currency shocks should be relatively uncommon.

FX impact should emerge from:

- Exposure direction
- Exposure size
- Exposure duration
- Currency movement
- Hedge coverage

The project must not predefine the final FX contribution to leakage.

---

# 15. Hedge Coverage

Not every foreign-currency exposure should be hedged.

The dataset should contain:

- Hedged exposures
- Partially hedged exposures
- Unhedged exposures

Hedge coverage may vary by:

- Currency
- Trade size
- Exposure duration
- Commercial policy

Hedging should reduce modeled FX exposure rather than guarantee
zero FX impact.

---

# 16. Shipment Timeline

International shipment durations should vary by route.

Typical modeled transit duration:

**5–45 calendar days**

The distribution should depend on:

- Origin country
- Destination country
- Route complexity
- Transport conditions

The majority of trades should fall within reasonable route-specific
ranges.

---

# 17. Shipment Delays

Shipment delays should be modeled separately from normal transit
time.

Possible delay causes include:

- Port congestion
- Documentation problems
- Customs issues
- Carrier delays
- Supplier readiness problems

Most shipments should experience no major delay.

A smaller proportion should experience:

- Minor delay
- Moderate delay
- Significant delay

The generator must avoid making operational problems universal.

---

# 18. Operational Cost

Operational costs may include:

- Freight
- Customs
- Handling
- Documentation
- Port charges
- Other trade-specific expenses

Expected operational costs should be estimated at trade approval.

Actual operational costs should vary around expectations.

Most trades should experience relatively small cost deviations.

Occasional trades may experience significant adverse cost variance.

---

# 19. Financing Assumption

Eastbridge uses a modeled annual financing rate for estimating the
cost of additional capital tied up by payment delays.

Initial project assumption:

**Annual Financing Rate: 10%**

This is a modeling assumption rather than a claim about Eastbridge's
actual borrowing cost.

---

# 20. Financing Day-Count Convention

The project uses:

**365 days per year**

for the financing-cost calculation.

Conceptually:

Financing Cost
=
Capital Tied Up
×
Annual Financing Rate
×
Delay Days
÷
365

The exact definition of "Capital Tied Up" will be implemented
consistently in the financial model.

---

# 21. Payment Delay and Financing Cost

Financing cost should primarily arise from additional capital being
tied up because of payment delays.

The model must avoid double counting the same delay effect.

Payment delay is therefore treated as:

**Operational/behavioral observation**

while financing cost is treated as:

**Financial consequence of additional capital duration**

---

# 22. Expected vs Actual Operational Cost

For each applicable trade:

Expected Operational Cost

and

Actual Operational Cost

must be separately represented.

The difference determines operational cost variance.

Operational Leakage
=
Actual Operational Cost
−
Expected Operational Cost

The treatment of favorable negative variances will be explicitly
documented in the implementation.

---

# 23. Other Leakage

Other Leakage is intentionally constrained.

Target:

**Normally ≤ 5% of total modeled leakage**

It exists only to represent small modeled differences that cannot
reasonably be assigned to the primary leakage categories.

It must not be used to hide model errors.

A large "Other" component is considered a data/model quality failure
and must trigger investigation.

---

# 24. Leakage Reconciliation Tolerance

The expected-profit bridge must reconcile within:

**₹1 per trade**

for the synthetic model, allowing for rounding.

Conceptually:

Expected Profit
− FX Impact
− Financing Cost
− Operational Leakage
− Other Leakage
≈ Realized Profit

If the difference exceeds the tolerance, the trade fails validation.

---

# 25. Risk Framework

Three independent risk components are modeled:

1. Payment Risk
2. FX Risk
3. Operational Risk

Each component is normalized to:

**0–100**

where:

0 = lowest modeled risk

100 = highest modeled risk

---

# 26. Payment Risk Weight

Initial Overall Risk weighting:

**Payment Risk = 40%**

Rationale:

Payment behavior directly affects:

- Cash availability
- Receivables
- Working capital
- Financing requirements

Payment risk therefore receives the highest initial weighting.

---

# 27. FX Risk Weight

Initial Overall Risk weighting:

**FX Risk = 30%**

Rationale:

FX exposure can materially change the INR-equivalent value of
foreign-currency transactions.

However, the actual financial impact depends on:

- Exposure direction
- Currency movement
- Exposure size
- Hedge coverage

Therefore FX receives a substantial but not dominant weight.

---

# 28. Operational Risk Weight

Initial Overall Risk weighting:

**Operational Risk = 30%**

Rationale:

Operational delays and cost variability can affect both timing and
profitability.

Operational risk is therefore given equal weighting to FX risk in the
initial model.

---

# 29. Overall Risk Index

Initial formula:

Overall Risk Index
=
(Payment Risk × 0.40)
+
(FX Risk × 0.30)
+
(Operational Risk × 0.30)

Because each component is already between 0 and 100, the resulting
index remains between 0 and 100.

---

# 30. Risk Bands

| Score | Band |
|---:|---|
| 0–30 | Low |
| 31–60 | Moderate |
| 61–80 | High |
| 81–100 | Critical |

These thresholds are intended to support management prioritization.

They are not statistical probabilities of default or loss.

---

# 31. Risk vs Exposure

Risk and exposure remain separate.

Risk describes the modeled level of adverse-outcome concern.

Exposure describes the financial amount currently subject to that
risk.

A high-risk trade with small exposure must not automatically outrank
a moderate-risk trade with extremely large exposure.

The Power BI decision system will therefore evaluate both dimensions.

---

# 32. Exposure Bands

Initial exposure classification:

| Exposure | Classification |
|---:|---|
| < ₹2M | Low |
| ₹2M–₹10M | Medium |
| ₹10M–₹30M | High |
| > ₹30M | Very High |

These thresholds are aligned with the intended Eastbridge trade-size
distribution.

They are used for prioritization rather than accounting treatment.

---

# 33. Active Trade Risk

Active trades must be scored using only information that would
reasonably be available at the assessment point.

The model must not use future:

- Payment outcomes
- Future FX movements
- Future operational events
- Final realized profit

when generating a pre-sign or active-trade risk assessment.

This prevents information leakage.

---

# 34. Historical Risk Features

Historical behavioral features may be calculated using information
available before the assessment date.

Examples:

- Customer historical late-payment rate
- Supplier historical delay rate
- Historical route performance
- Historical currency volatility
- Historical hedge coverage

Historical lookback windows will be defined during implementation.

---

# 35. Synthetic Data Generation Principle

The generator must follow:

Business Assumptions
        ↓
Behavioral Personas
        ↓
Probability Distributions
        ↓
Synthetic Records
        ↓
Validation
        ↓
Analysis

The generator must NOT follow:

Desired Finding
        ↓
Artificial Data
        ↓
Forced Dashboard Conclusion

---

# 36. Behavioral Independence

Not every variable should be perfectly correlated.

For example:

- A large trade does not automatically mean high risk.
- A particular country does not automatically mean poor performance.
- A foreign-currency trade does not automatically create an FX loss.
- A late shipment does not automatically create a large financial loss.
- A high-risk customer does not need to be the largest customer.

Relationships should exist where economically reasonable, but
random variation must remain.

---

# 37. Outlier Principle

Real businesses contain unusual transactions.

The synthetic dataset should therefore contain a small number of:

- Very large trades
- Significant payment delays
- Large operational cost variances
- Meaningful FX movements

However, extreme outliers must remain plausible and relatively rare.

---

# 38. Data Quality Rules

Generated data must satisfy:

1. Foreign keys must reference valid entities.
2. Dates must follow logical event order.
3. Payment dates cannot precede invoice/payment initiation dates.
4. Shipment completion cannot occur before shipment start.
5. Actual operational costs cannot be missing for completed trades.
6. Completed trades must contain sufficient information for
   reconciliation.
7. Active trades must not contain fabricated future outcomes.
8. FX rates must exist for applicable exposure dates.
9. Currency must match the associated FX rate.
10. Risk scores must remain within 0–100.
11. Risk bands must match risk scores.
12. Leakage reconciliation must pass tolerance.
13. Duplicate business events must be investigated.
14. Missing values must be intentional and documented.

---

# 39. Business Findings Are Not Predetermined

The project explicitly prohibits hard-coding conclusions such as:

- Supplier X is the worst supplier.
- Country Y causes the most leakage.
- FX contributes exactly 30% of leakage.
- Payment delays cause exactly ₹X of loss.
- High-risk trades must produce the largest losses.

The dataset is designed to create realistic conditions.

The analysis determines the findings.

---

# 40. Expected Analytical Behavior

The dataset should contain enough behavioral variation that the final
analysis can reasonably discover:

- Concentrated financial exposure
- Different customer payment behaviors
- Different supplier performance levels
- Route-level operational differences
- Currency exposure differences
- Variation between expected and realized outcomes
- Risk concentrations

The exact ranking and magnitude must emerge from analysis.

---

# 41. Assumption Change Governance

If an assumption changes after data generation begins, the project
must:

1. Document the change.
2. Explain why it changed.
3. Regenerate affected data if necessary.
4. Re-run validation.
5. Re-run affected analysis.
6. Record the change in Git history.

No silent changes to core business assumptions are permitted.

---

# 42. Final Business Constitution

The Eastbridge synthetic environment therefore follows:

Realistic Business Behavior
+
Explicit Financial Definitions
+
Transparent Risk Rules
+
Controlled Synthetic Data
+
Independent Validation
=
Credible Analytical Environment

The project must allow the final business findings to emerge from
evidence rather than from assumptions.

