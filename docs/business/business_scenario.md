# Eastbridge Business Scenario & Trade Lifecycle

**Document Status:** Draft for Project Build  
**Project:** Trade Finance Risk & Margin Leakage Intelligence

---

# 1. Business Problem

Eastbridge management has identified a recurring disconnect between
expected trade profitability and the company's actual cash-flow and
financial performance.

At the time a trade is approved, management expects the transaction
to generate a defined commercial margin.

However, the final financial outcome can differ because the trade
takes time to complete and settle.

During that period:

- Customers may pay later than contractual terms.
- Foreign exchange rates may move against or in favor of Eastbridge.
- Shipments may be delayed.
- Customs or documentation issues may create additional costs.
- Working capital may remain tied up for longer than expected.

The business therefore needs to understand not only whether a trade
was profitable, but **why its expected financial outcome changed**.

---

# 2. Core Management Question

The central business question is:

> "We're profitable on paper, but our cash flow is always tight, and
> some trades that should be profitable end up barely breaking even.
> Why, and which deals or partners are causing it?"

The analytical system is designed to answer this question at three
levels:

### Enterprise Level

How much profit and cash-flow exposure exists across the business?

### Counterparty / Route Level

Which customers, suppliers, countries, currencies and routes
contribute most to the exposure?

### Trade Level

Which active trades require management attention now?

---

# 3. What the Project Means by "Leakage"

The project does not treat every difference between expected and
realized financial results as an unexplained loss.

Instead, the expected-to-realized change is decomposed into explicit
business components.

The intended analytical bridge is:

Expected Trade Profit
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

The fundamental relationship is:

Expected Profit
− FX Impact
− Financing Cost
− Operational Leakage
− Other
≈ Realized Profit

Any material unexplained difference must be investigated before
management conclusions are presented.

---

# 4. Trade Lifecycle

A typical Eastbridge trade moves through the following stages:

Customer Requirement
        ↓
Commercial Evaluation
        ↓
Trade Approval
        ↓
Supplier Procurement
        ↓
Shipment Planning
        ↓
International Shipment
        ↓
Customs / Documentation
        ↓
Customer Delivery
        ↓
Customer Receivable
        ↓
Customer Payment
        ↓
Supplier / Trade Settlement
        ↓
FX Settlement
        ↓
Realized Financial Outcome

Each stage may create data that is relevant to the final analysis.

---

# 5. Stage 1 — Customer Requirement

A business customer identifies a requirement for one or more
products.

Eastbridge evaluates:

- Product requirements
- Quantity
- Expected selling price
- Expected procurement cost
- Expected logistics cost
- Expected customs cost
- Customer payment terms
- Expected trade margin

At this stage, the trade is primarily an expected commercial
opportunity.

---

# 6. Stage 2 — Trade Approval

Before committing resources, Eastbridge evaluates whether the trade
should be approved.

Relevant considerations include:

- Expected profit
- Customer payment terms
- Supplier reliability
- Route characteristics
- Currency exposure
- Trade size
- Historical counterparty behavior

The final project will eventually support a structured pre-sign
risk assessment at this stage.

---

# 7. Stage 3 — Supplier Procurement

After approval, Eastbridge places the required order with the
supplier.

The supplier may be located in a different country and may require
payment in a foreign currency.

This creates potential:

- Supplier performance exposure
- Procurement cost exposure
- FX exposure
- Supplier payment obligations

---

# 8. Stage 4 — Shipment

The products are transported from the supplier to the destination
market.

Shipment performance can differ from the original plan.

Potential events include:

- Shipment delays
- Port congestion
- Documentation problems
- Customs delays
- Transit delays
- Partial shipments
- Delivery delays

These events can affect both timing and cost.

---

# 9. Stage 5 — Operational Cost

Before the trade is completed, Eastbridge expects certain operating
costs.

Examples include:

- Freight
- Customs
- Documentation
- Handling
- Port-related charges
- Other operational costs

The analysis compares expected and actual operational costs.

Therefore:

Operational Leakage
=
Actual Operational Cost
−
Expected Operational Cost

A negative variance represents a saving rather than leakage.

---

# 10. Stage 6 — Customer Receivable

Once the customer becomes liable for payment, Eastbridge records a
receivable.

The customer has a contractual payment due date.

For example:

Trade Date: 10 March  
Contractual Payment Terms: 60 days  
Due Date: 9 May

The payment is then monitored against the contractual due date.

---

# 11. Stage 7 — Payment Behavior

The actual payment date may differ from the contractual due date.

The project defines:

Payment Delay
=
Actual Payment Date
−
Contractual Due Date

Positive values represent late payment.

A negative value represents early payment.

For an unpaid active trade, the payment remains outstanding rather
than being assigned an artificial payment date.

Payment behavior contributes to:

- Working-capital exposure
- Financing cost
- Payment risk

---

# 12. Stage 8 — FX Exposure

FX exposure exists when a trade creates a foreign-currency obligation
or receivable whose INR value can change before settlement.

The analysis considers:

- Currency
- Foreign-currency amount
- Exposure creation date
- Expected settlement date
- Actual settlement date
- Baseline FX rate
- Settlement FX rate
- Hedge status

FX movement is not automatically considered a loss.

An exchange-rate movement can create either:

- An unfavorable financial impact
- A favorable financial impact

The direction depends on the nature of the exposure.

---

# 13. Stage 9 — Working-Capital Financing

When customer payments are delayed, Eastbridge may have capital tied
up for longer than originally expected.

The project estimates the financing impact associated with this
additional duration.

Conceptually:

Financing Cost
=
Capital Tied Up
×
Financing Rate
×
Delay Duration

The final implementation will define the precise calculation and
time convention in the business assumptions document.

---

# 14. Stage 10 — Realized Profit

Once the relevant trade costs, FX impacts and financing effects have
been identified, Eastbridge can evaluate the realized financial
outcome.

The analytical objective is to explain the movement from:

Expected Profit

to:

Realized Profit

rather than simply reporting the final number.

---

# 15. Example Trade Journey

Consider a simplified Eastbridge transaction.

A customer requests networking equipment.

Eastbridge estimates:

Expected Revenue
= ₹10,000,000

Expected total trade costs
= ₹8,500,000

Therefore:

Expected Profit
= ₹1,500,000

The trade is approved.

During execution:

- The shipment experiences a delay.
- The customer pays later than contractual terms.
- The supplier obligation is denominated in USD.
- The INR/USD rate changes before settlement.
- Additional operational costs are incurred.

The final financial result is therefore different from the original
expectation.

The analytical system should be able to explain the difference as:

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

The actual magnitude of each component must emerge from the
generated data.

---

# 16. Active vs Completed Trades

The project contains two important populations.

## Completed Trades

These trades have sufficient historical information to evaluate:

- Actual payment behavior
- Operational performance
- FX outcome
- Realized financial result
- Historical risk behavior

They are primarily used for historical analysis.

## Active Trades

These trades are still in progress.

Some future outcomes are therefore unknown.

They are primarily used for:

- Current financial exposure
- Current risk assessment
- Management prioritization
- Pre-sign / in-progress decision support

The project must not use future information to artificially score
an active trade.

---

# 17. Risk vs Exposure

Risk and financial exposure are deliberately treated as separate
concepts.

A trade can be:

### High Risk + Low Exposure

The probability or severity of an adverse outcome may be high, but
the financial amount involved is relatively small.

### Low Risk + High Exposure

The trade may have reliable counterparties and stable operations,
but a very large amount of capital may be exposed.

### High Risk + High Exposure

This represents the highest management priority.

The final Power BI system will therefore use a:

**Risk × Exposure Priority Matrix**

rather than ranking trades only by risk score.

---

# 18. Management Decisions Supported

The eventual analytical system should support decisions such as:

### Finance / Treasury

- Where is working capital tied up?
- Where is FX exposure concentrated?
- Which exposures require attention?

### Commercial Management

- Which customers create persistent payment pressure?
- Should payment terms or credit limits be reconsidered?

### Operations

- Which suppliers and routes create operational leakage?
- Where should operational improvements be prioritized?

### Trade / Procurement

- Should a new trade be approved?
- What conditions should be attached to approval?

### CFO / Senior Leadership

- How much profit is at risk?
- Where is the largest financial exposure?
- Which interventions are likely to produce measurable savings?

---

# 19. Analytical Principle

Every major analysis must follow:

Question
    ↓
Analysis
    ↓
Finding
    ↓
Decision
    ↓
Expected Financial Impact

The project is therefore designed as a decision-support system,
not simply a reporting dashboard.

---

# 20. Scope Boundary

The project intentionally focuses on:

- Trade profitability
- Payment behavior
- Working-capital effects
- FX exposure
- Operational leakage
- Risk assessment
- Management decision support

It does not attempt to simulate:

- Full accounting systems
- Tax accounting
- Payroll
- Inventory management
- Real-time banking systems
- Actual banking transactions
- Real-time FX feeds
- Machine-learning prediction
- Automated trade execution

The purpose is to build a credible Business Analyst portfolio
project with a clearly controlled scope.
