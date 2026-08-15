# Eastbridge Global Trading Pvt. Ltd.
## Company Profile

**Document Status:** Draft for Project Build  
**Project:** Trade Finance Risk & Margin Leakage Intelligence  
**Base Currency:** INR  
**Business Type:** B2B Import-Export Trading  
**Primary Market:** India  
**Analysis Period:** January 2024 – December 2026

---

## 1. Company Overview

Eastbridge Global Trading Pvt. Ltd. is a fictional mid-sized B2B
import-export trading company headquartered in India.

The company sources industrial technology and electronics products
from international suppliers and sells them to business customers
across India and selected international markets.

Eastbridge does not manufacture the majority of the products it sells.
Its business model depends on purchasing products from suppliers,
coordinating international logistics, managing trade documentation,
and selling those products to commercial customers.

The company's profitability therefore depends not only on its selling
margin, but also on payment timing, foreign exchange movements,
logistics performance, customs-related costs, and working-capital
requirements.

---

## 2. Core Product Categories

Eastbridge primarily trades products across five categories:

1. Networking Equipment
2. Data Center Hardware
3. Industrial Electronics
4. Security Equipment
5. Power & Connectivity

Example products include:

- Enterprise routers
- Managed network switches
- Firewall appliances
- Network modules
- Server racks
- UPS systems
- Industrial controllers
- CCTV equipment
- Access-control equipment
- Fiber-optic transceivers

---

## 3. Geographic Operating Model

Eastbridge operates primarily from India.

### Supplier Markets

The company sources products from international suppliers located
primarily across:

- China
- Singapore
- Germany
- United Kingdom
- United States

### Customer Markets

Eastbridge's customers are primarily located in:

- India
- United Arab Emirates
- Singapore
- Selected Southeast Asian markets

The company therefore manages multiple international trade routes
with different transit times, currencies, documentation requirements,
and operational characteristics.

---

## 4. Currency Environment

Eastbridge uses **Indian Rupees (INR)** as its accounting and reporting
currency.

International trade transactions may be denominated in:

- USD
- EUR
- GBP
- CNY

This creates foreign-exchange exposure whenever contractual
obligations are denominated in a foreign currency and settlement
occurs later.

FX exposure is therefore treated as a business risk rather than
automatically being classified as a financial loss.

---

## 5. Trade Lifecycle

A typical Eastbridge transaction follows this process:

Customer Requirement
        ↓
Commercial Quote
        ↓
Trade Approval
        ↓
Supplier Procurement
        ↓
Shipment Planning
        ↓
International Transportation
        ↓
Customs / Documentation
        ↓
Customer Delivery
        ↓
Customer Payment
        ↓
Supplier / Trade Settlement
        ↓
Realized Financial Outcome

Different stages of this lifecycle can create financial or
working-capital pressure.

---

## 6. Typical Trade Characteristics

Eastbridge handles a mixture of small, medium, and large B2B trades.

Trade sizes are intentionally modeled using a skewed distribution
rather than a uniform random distribution because large commercial
transactions generally represent a smaller number of trades while
accounting for a significant share of total business value.

Customer payment terms may range from short-term settlement to
extended commercial credit arrangements.

Supplier payment terms vary according to supplier relationship,
country, negotiation history, and trade structure.

---

## 7. Business Model

Eastbridge earns its gross margin primarily through the difference
between the commercial selling value of a trade and the associated
procurement and operating costs.

However, the expected commercial margin can change between trade
approval and final settlement.

Potential drivers include:

- Foreign-exchange movements
- Customer payment delays
- Working-capital financing costs
- Shipment delays
- Customs and documentation issues
- Unexpected operational costs
- Other trade-specific financial variations

The project therefore evaluates both expected and realized
financial outcomes.

---

## 8. Why Management Needs This Analysis

Management has observed a recurring business problem:

> The company appears profitable based on expected trade margins,
> but cash flow remains under pressure and some completed trades
> produce significantly less profit than originally expected.

Management wants to understand:

- Where expected profit disappears
- Which customers create working-capital pressure
- Where FX exposure is concentrated
- Which suppliers or routes create operational leakage
- Which active trades require immediate attention
- Whether risky trades can be identified before approval

---

## 9. Project Scope

This project focuses on:

- Trade-level financial analysis
- Payment behavior
- Working-capital exposure
- FX exposure
- Operational performance
- Expected vs realized profit
- Transparent trade risk scoring
- Management decision support

The project does not attempt to simulate every function of a real
trading company.

The synthetic environment is intentionally limited to the business
processes necessary to answer the defined management questions.

---

## 10. Important Modeling Principle

Eastbridge's synthetic data will be generated from business
behavioral assumptions.

The analysis will **not** predetermine the final business findings.

For example, the project will not assume in advance that:

- FX is the largest source of leakage
- A particular supplier is the worst performer
- Payment delays are responsible for a fixed percentage of leakage

Those outcomes must emerge from the generated data and subsequent
analysis.

---

## 11. Intended Management Outcome

The final analytical system should allow Eastbridge management to
move from:

> "We know there is a cash-flow problem."

to:

> "We know which trades, counterparties, currencies, routes and
> operational conditions are contributing to the problem, how much
> financial exposure is involved, and what action should be taken."
