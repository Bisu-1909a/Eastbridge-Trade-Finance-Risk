# Eastbridge Trade Finance Risk & Margin Leakage Intelligence

A Business Analyst portfolio project that analyzes trade-finance exposure, foreign-exchange risk, payment status, operational events, and management priorities for a fictional B2B import-export trading company.

The project combines SQL-based risk analysis, Python data preparation and validation, a SQLite database, and an interactive Power BI reporting system.

## 1. Business Problem

International trading companies face several interconnected risks:

* Outstanding invoices and payment delays
* Foreign-exchange exposure
* Inadequate or partial hedging
* Shipment delays and operational events
* Financial exposure across individual trade deals
* Difficulty prioritizing trades that require management attention

Eastbridge provides a structured analytical approach to examining these risks and supporting management decisions.

## 2. Project Objectives

The project aims to:

* Analyze trades from order through payment and shipment.
* Examine financial and foreign-exchange exposure.
* Identify high-priority trades requiring review.
* Analyze exposure across risk priorities, currencies, hedge types, and hedge statuses.
* Organize management actions into a decision queue.
* Present trade-level risk information through Power BI dashboards.
* Support reproducible analysis through documented SQL queries and Python validation scripts.
* Identify trade-level financial and foreign-exchange exposure to help management prioritize risk reviews and follow-up actions.


## 3. Technology Stack

| Technology     | Purpose                                                              |
| -------------- | -------------------------------------------------------------------- |
| SQL            | Risk analysis, aggregation, reconciliation, and reporting datasets   |
| Python         | Data generation, database initialization, extraction, and validation |
| pandas         | Structured data processing and CSV handling                          |
| NumPy          | Numerical data-processing support where applicable                   |
| SQLite         | Relational database                                                  |
| Power BI       | Interactive dashboards and management reporting                      |
| Git and GitHub | Version control and project documentation                            |

## 4. Project Architecture

The project follows this general workflow:

1. Generate synthetic master and transaction data.
2. Store the data in CSV files.
3. Initialize the SQLite database.
4. Load and validate the data.
5. Run SQL-based risk analyses.
6. Prepare the final Power BI dataset.
7. Explore risk exposure and management priorities in Power BI.

See `docs/data/data_pipeline.md` for the data pipeline and `docs/project_runbook.md` for the documented execution and validation process.

## 5. Database Overview

The SQLite database is located at:

`database/eastbridge.db`

It contains 15 tables:

* `country`
* `currency`
* `customer`
* `supplier`
* `product`
* `route`
* `trade`
* `invoice`
* `payment`
* `financial_event`
* `shipment`
* `operational_event`
* `fx_exposure`
* `fx_rate`
* `hedge`

The database separates reference data, trade transactions, payment information, shipment events, and foreign-exchange risk information.

**Data limitation:** The `financial_event` and `fx_rate` tables currently exist but contain no records. Analyses that depend on those records must account for this limitation.

The project uses synthetic data for demonstration and portfolio purposes. Its results should not be interpreted as actual company financial data.

## 6. SQL Analysis

SQL analysis scripts are organized under:

`sql/analysis/`

The numbered scripts cover areas including:

* Outstanding and overdue exposure
* Trade-level risk
* Foreign-exchange exposure
* Hedge status and hedge effectiveness
* Combined financial and FX risk
* Risk-priority summaries
* Exposure concentration
* Management action queues
* Executive reporting metrics
* Data integrity and exposure reconciliation

The final Power BI dataset is prepared by:

`sql/analysis/63_final_powerbi_risk_dataset.sql`

See `docs/sql_analysis_guide.md` for the documented progression of the SQL analysis.

## 7. Python Components

Python source files are organized under `python/`.

The project includes components for:

* Generating synthetic data
* Initializing the SQLite database
* Loading data
* Inspecting database contents
* Validating master data and transaction records
* Checking relationships and foreign-key integrity
* Preparing a trade-level Power BI dataset

The individual scripts should be executed according to their dependencies and the sequence documented in `docs/project_runbook.md`.

## 8. Power BI Dashboard

The Power BI report is located at:

`data/powerbi/Eastbridge-Trade-Finance-Risk-Dashboard.pbix`

The final dataset is located at:

`data/powerbi/final_risk_dataset.csv`

The interactive Power BI report contains **eight pages**:

1. **Executive Overview** — High-level trade-risk indicators and business performance summaries.
2. **FX & Hedge Risk Analysis** — Foreign-exchange exposure and hedge analysis.
3. **Operational & Payment Risk** — Operational events and payment-related risk.
4. **Risk Exposure Overview** — Financial exposure, FX exposure, combined exposure, and risk categories.
5. **Management Decision & Action** — Management-focused risk assessment and recommended actions.
6. **Executive Risk Overview** — Executive risk indicators and priority summaries.
7. **Management Decision Queue** — Prioritized trades and recommended management actions.
8. **Risk Investigation** — Trade-level investigation using Trade ID selection.

The final dataset contains **100 trades and 11 columns**. Its current risk-priority distribution is:

| Risk priority | Number of trades |
| ------------- | ---------------: |
| Critical      |                3 |
| High          |               13 |
| Medium        |               14 |
| Low           |               70 |
| Total         |              100 |

These classifications reflect the project's implemented risk rules and synthetic dataset. They are not externally validated financial-risk ratings.


## 9. Data Quality and Validation

Validation scripts are located under:

`python/validation/`

The documented validation process covers:

* Database schema
* Master data
* Trades
* Invoices
* Payments
* Shipments
* Operational events
* FX exposures
* Hedges
* Relationships between records

The database has passed the documented foreign-key integrity check with zero reported violations.

The final Power BI CSV has also been checked for row count, unique trade IDs, duplicate IDs, missing values, and risk-priority distribution.

See `docs/project_runbook.md` for expected validation results and the reproducibility checklist.

## 10. Repository Structure

Eastbridge-Trade-Finance-Risk/
├── dashboard/
├── data/
│   ├── raw/
│   └── powerbi/
├── database/
├── docs/
│   ├── business/
│   ├── data/
│   ├── project_runbook.md
│   └── sql_analysis_guide.md
├── python/
│   ├── data_generation/
│   ├── generators/
│   ├── loaders/
│   ├── validation/
│   ├── init_database.py
│   └── powerbi_extract.py
├── sql/
│   ├── analysis/
│   ├── schema/
│   └── validation/
├── .gitignore
├── README.md
└── requirements.txt


Some directories are reserved for supporting project work and may not yet contain deliverables.

## 11. Reproducibility

The project includes database initialization, data-generation scripts, validation scripts, SQL analyses, and a documented runbook.

For the correct execution order, prerequisites, validation commands, and Power BI workflow, follow:

`docs/project_runbook.md`

Do not assume that every dataset can be regenerated independently or that every source table is populated. Follow the documented dependencies and limitations.

## 12. Project Status
**Current stage:** The core database, synthetic datasets, SQL risk analysis, validation scripts, documentation, and Power BI reporting have been developed.

**Remaining work:** Final repository review, documentation and reproducibility checks, dashboard presentation polish, and publication preparation.


This is a portfolio project intended to demonstrate analytical thinking, structured risk assessment, data validation, and business-oriented reporting.
