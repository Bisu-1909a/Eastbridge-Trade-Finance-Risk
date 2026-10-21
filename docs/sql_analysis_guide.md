# SQL Analysis Guide

## Purpose

The SQL analysis layer transforms the Eastbridge trade finance dataset into
business-focused risk, exposure, and management decision outputs.

The analysis progresses from individual trade exposure to FX risk,
combined risk, executive summaries, management actions, validation,
reconciliation, and the final Power BI dataset.

---

## Analysis Structure

### 00–10: Core Trade Risk Analysis

These queries establish the initial trade-level risk analysis.

Key outputs include:

- Outstanding exposure
- Overdue exposure
- Combined trade risk
- Critical trade identification
- Risk category summaries
- Executive risk KPIs

Primary reference:

- `00_canonical_trade_risk.sql`
- `06_combined_trade_risk.sql`
- `10_executive_risk_kpis.sql`

---

### 11–23: FX and Hedge Risk Analysis

These queries analyze foreign-exchange exposure and hedge coverage.

Key outputs include:

- FX exposure
- FX risk by currency
- FX risk by hedge type
- FX risk by hedge status
- Unhedged FX trades
- Hedge effectiveness
- FX management action queues

Primary reference:

- `11_fx_risk_exposure.sql`
- `13_fx_risk_by_currency.sql`
- `16_top_unhedged_fx_trades.sql`
- `22_hedge_effectiveness.sql`

---

### 24–49: Combined and Executive Risk Analysis

These queries combine financial and FX exposure into management-oriented
risk views.

Key outputs include:

- Combined financial and FX risk
- Risk priority
- Risk concentration
- Executive risk summaries
- Management action queues
- Risk analysis by currency, hedge type, hedge status, and trade status

Primary reference:

- `24_combined_financial_fx_risk.sql`
- `25_combined_risk_priority_queue.sql`
- `35_executive_risk_overview.sql`
- `37_management_action_queue.sql`
- `41_top_combined_risk_trades.sql`
- `48_executive_dashboard_kpis.sql`

---

### 50–57: Management Decisions and Validation

These queries move the analysis toward the final management decision layer.

Key outputs include:

- Final management decision queue
- Executive decision summaries
- Management action analysis
- Final executive validation

Primary reference:

- `50_final_management_decision_queue.sql`
- `51_executive_decision_summary.sql`
- `57_final_executive_validation.sql`

---

### 58–62: Audit and Reconciliation

These queries validate the exposure calculations and reconcile the
financial and FX components before the final reporting dataset is produced.

Primary reference:

- `58_financial_exposure_audit.sql`
- `60_exposure_reconciliation.sql`
- `61_final_sql_integrity_check.sql`
- `62_executive_exposure_reconciliation.sql`

---

### 63: Final Power BI Dataset

`63_final_powerbi_risk_dataset.sql` produces the final trade-level dataset
used by the Power BI reporting layer.

Output:

`data/powerbi/final_risk_dataset.csv`

The dataset contains:

- Trade identifier
- Trade status
- Currency
- Financial exposure
- FX exposure
- Combined exposure
- Hedge status
- Hedge type
- Risk priority
- Risk rank
- Management action

This file is the primary SQL-to-Power-BI handoff.

---

## Validation Principle

The final reporting dataset should be treated as the controlled output of
the validated SQL analysis pipeline.

Validation is performed before the dataset is consumed by Power BI.

The final analysis stage therefore follows:

SQL analysis
→ validation
→ reconciliation
→ final reporting dataset
→ Power BI
