# EastBridge Trade Finance Risk & Margin Leakage Intelligence

## Project Runbook

## 1. Purpose

This runbook documents how to reproduce and validate the EastBridge Trade Finance Risk & Margin Leakage Intelligence project from the repository.

The project uses Python for synthetic data generation, database initialization, data loading, validation, SQL-based risk analysis, and Power BI reporting.

The main pipeline is:

```text
Synthetic Data Generation
        |
        v
Raw CSV Data
        |
        v
SQLite Database Initialization
        |
        v
Data Loading
        |
        v
Data Validation
        |
        v
SQL Risk Analysis
        |
        v
Final Power BI Dataset
        |
        v
Power BI Executive Reporting
```

---

## 2. Prerequisites

Required:

* Python 3.x
* Git
* Power BI Desktop
* A local clone of the Eastbridge-Trade-Finance-Risk repository

From the repository root, install Python dependencies:

```powershell
pip install -r requirements.txt
```

---

## 3. Project Execution Order

The project should be executed in dependency order.

### Step 1 - Generate Master Data

Generate the foundational country and currency data first:

```powershell
python python\data_generation\generate_countries.py
python python\data_generation\generate_currencies.py
```

Generate the master entities that depend on countries:

```powershell
python python\data_generation\generate_customers.py
python python\data_generation\generate_suppliers.py
python python\data_generation\generate_products.py
python python\data_generation\generate_routes.py
```

---

### Step 2 - Generate Trade Data

Generate trades after the required master data exists:

```powershell
python python\data_generation\generate_trades.py
```

---

### Step 3 - Generate Transaction Data

Generate invoices and payments:

```powershell
python python\data_generation\generate_invoices.py
python python\data_generation\generate_payments.py
```

---

### Step 4 - Generate Shipment and Operational Data

Generate shipment records:

```powershell
python python\data_generation\generate_shipments.py
```

Generate operational events from shipment data:

```powershell
python python\data_generation\generate_operational_events.py
```

---

### Step 5 - Generate FX and Hedge Data

Generate FX exposure data:

```powershell
python python\data_generation\generate_fx_exposures.py
```

Generate hedge records:

```powershell
python python\generators\generate_hedges.py
```

---

## 4. Database Initialization

Initialize the SQLite database from the project schema:

```powershell
python python\init_database.py
```

The database is created at:

```text
database/eastbridge.db
```

The schema is maintained in:

```text
sql/schema/schema.sql
```

The database schema contains 15 tables covering:

* Countries
* Currencies
* Customers
* Suppliers
* Products
* Routes
* Trades
* Invoices
* Payments
* Financial events
* Shipments
* Operational events
* FX exposures
* FX rates
* Hedges

---

## 5. Data Loading Order

Load data according to table dependencies.

### Master Data

```powershell
python python\loaders\load_countries.py
python python\loaders\load_currencies.py
python python\loaders\load_customers.py
python python\loaders\load_suppliers.py
python python\loaders\load_products.py
python python\loaders\load_routes.py
```

### Trade Data

```powershell
python python\loaders\load_trades.py
```

### Transaction Data

```powershell
python python\loaders\load_invoices.py
python python\loaders\load_payments.py
```

### Shipment and Operational Data

```powershell
python python\loaders\load_shipments.py
python python\loaders\load_operational_events.py
```

### FX and Hedge Data

```powershell
python python\loaders\load_fx_exposures.py
python python\loaders\load_hedges.py
```

---

## 6. Validation

Validation scripts are located in:

```text
python/validation/
```

### Schema Validation

```powershell
python python\validation\validate_schema.py
```

### Master Data Validation

```powershell
python python\validation\validate_master_data.py
```

### Trade Validation

```powershell
python python\validation\validate_trades.py
```

### Invoice Validation

```powershell
python python\validation\validate_invoices.py
```

### Payment Validation

```powershell
python python\validation\validate_payments.py
```

### Shipment Validation

```powershell
python python\validation\validate_shipments.py
```

### Operational Event Validation

```powershell
python python\validation\validate_operational_events.py
```

### FX Exposure Validation

```powershell
python python\validation\validate_fx_exposures.py
```

### Hedge Validation

```powershell
python python\validation\validate_hedges.py
```

### Cross-table Relationship Validation

```powershell
python python\validation\validate_relationships.py
```

All validation scripts should pass before the SQL analysis and reporting layers are treated as final.

---

## 7. Database Inspection

For a quick database overview:

```powershell
python python\validation\inspect_database.py
```

This can be used to inspect the populated SQLite database after loading.

---

## 8. Referential Integrity Check

The database should have no foreign-key violations.

Use:

```powershell
python -c "import sqlite3; c=sqlite3.connect('database/eastbridge.db'); c.execute('PRAGMA foreign_keys=ON'); rows=c.execute('PRAGMA foreign_key_check').fetchall(); print('Foreign key violations:', len(rows)); [print(r) for r in rows]; c.close()"
```

Expected result:

```text
Foreign key violations: 0
```

---

## 9. SQL Risk Analysis

SQL analysis files are located in:

```text
sql/analysis/
```

The SQL analysis progresses from basic exposure calculations to executive risk and management decision analysis.

The SQL progression is documented in:

```text
docs/sql_analysis_guide.md
```

The final Power BI dataset query is:

```text
sql/analysis/63_final_powerbi_risk_dataset.sql
```

The SQL analysis layer is responsible for producing management-oriented risk information such as:

* Financial exposure
* FX exposure
* Combined exposure
* Risk priority
* Risk ranking
* Management action
* Trade-level risk concentration

---

## 10. Final Power BI Dataset

The final reporting dataset is exported to:

```text
data/powerbi/final_risk_dataset.csv
```

This dataset contains the fields required by the Power BI executive reporting layer, including:

```text
trade_id
trade_status
currency_id
financial_exposure
fx_exposure
combined_exposure
hedge_status
hedge_type
risk_priority
risk_rank
management_action
```

---

## 11. Power BI Reporting

The Power BI report is stored under:

```text
data/powerbi/
```

The report contains management-oriented views covering:

* Executive Overview
* FX & Hedge
* Operational & Payment
* Risk Exposure Overview
* Executive Risk Overview
* Management Decision Queue
* Trade Risk Investigation

The final Power BI dataset should be refreshed/imported after the SQL analysis has been completed.

---

## 12. Expected Validation Results

The current validated synthetic dataset contains:

| Entity             | Expected Count |
| ------------------ | -------------: |
| Countries          |             10 |
| Currencies         |             10 |
| Customers          |             10 |
| Suppliers          |             10 |
| Products           |             10 |
| Routes             |             10 |
| Trades             |            100 |
| Invoices           |            100 |
| Payments           |            100 |
| Shipments          |            100 |
| Operational Events |            260 |
| FX Exposures       |            100 |
| Hedges             |            100 |

The database currently passes:

```text
Foreign key violations: 0
```

The final risk dataset contains 100 trade-level records.

---

## 13. Reproducibility Principle

The project should be reproducible from the repository rather than depending on undocumented manual database changes.

The intended process is:

```text
Generate
   |
   v
Load
   |
   v
Validate
   |
   v
Analyze
   |
   v
Export
   |
   v
Report
```

Any change to the schema, generation logic, loading logic, validation rules, or SQL risk calculations should be followed by the relevant validation steps before the Power BI reporting layer is considered final.

---

## 14. Important Notes

The SQLite schema contains `financial_event` and `fx_rate` tables.

The current synthetic-data pipeline does not include corresponding raw CSV generation/loading steps for these two tables. They therefore remain part of the schema but are not required by the currently validated trade-risk reporting dataset.

The primary reporting risk calculations currently use:

* Financial exposure
* FX exposure
* Combined exposure
* Hedge status
* Risk priority
* Risk ranking
* Management action

The Power BI report uses the final SQL-derived dataset rather than relying on undocumented manual calculations.

---

## 15. Final Reproducibility Checklist

Before considering the project reproducible and presentation-ready:

* [ ] Install dependencies
* [ ] Generate required raw data
* [ ] Initialize SQLite database
* [ ] Load data in dependency order
* [ ] Validate schema
* [ ] Validate master data
* [ ] Validate trades
* [ ] Validate invoices
* [ ] Validate payments
* [ ] Validate shipments
* [ ] Validate operational events
* [ ] Validate FX exposures
* [ ] Validate hedges
* [ ] Validate cross-table relationships
* [ ] Confirm zero foreign-key violations
* [ ] Run final SQL analysis
* [ ] Export final Power BI dataset
* [ ] Refresh Power BI report
* [ ] Perform final Power BI presentation QA
