# EastBridge Data Pipeline

## 1. Purpose

The EastBridge data pipeline defines how synthetic trade finance business data
moves from source generation through validation, processing, database loading,
SQL analysis, and Power BI reporting.

The pipeline is designed to produce a controlled analytical dataset that
supports trade exposure analysis, FX risk analysis, risk prioritization, and
management decision-making.

---

## 2. End-to-End Pipeline

```text
Synthetic Data Generation
          |
Raw CSV Files
          |
Data Validation
          |
Processed Data
          |
SQLite Database
          |
SQL Risk Analysis
          |
Validation & Reconciliation
          |
Final Power BI Dataset
          |
Power BI Dashboard
          |
Management Decision Support
```

---

## 3. Synthetic Data Generation

EastBridge uses synthetic trade finance data to simulate realistic business
transactions without relying on confidential company data.

The generated data represents trade-level information such as:

- Trade details
- Customers
- Suppliers
- Invoices
- Payments
- FX exposure
- Hedge information
- Operational information

The synthetic dataset is designed to support realistic risk and margin
analysis while remaining safe for portfolio use.

---

## 4. Raw Data

Generated source records are stored as raw CSV files.

Raw data represents the original generated records before analytical
processing or database transformation.

The raw layer provides traceability between generated source data and the
final analytical results.

---

## 5. Data Validation

Before loading data into the analytical database, validation checks are
performed.

Validation focuses on:

- Required fields
- Record counts
- Duplicate records
- Missing values
- Referential consistency
- Numeric values
- Business-rule consistency

The purpose of validation is to prevent invalid source data from entering
the analytical layer.

---

## 6. Processed Data

Validated data is prepared for database loading and analysis.

Processing ensures that:

- Data types are consistent
- Required relationships are maintained
- Business entities can be loaded into the database
- Analytical calculations can be performed reliably

The processed layer acts as the bridge between source data and the SQLite
database.

---

## 7. SQLite Database

Validated and processed data is loaded into a SQLite analytical database.

The database contains the structured trade finance entities required for
analysis.

The database provides the central source for SQL-based business analysis.

---

## 8. SQL Risk Analysis

SQL is used to transform transactional data into business insights.

The analysis covers areas including:

- Financial exposure
- FX exposure
- Combined exposure
- Hedge status
- Risk priority
- Trade status
- Management actions
- Risk concentration

The SQL analysis layer converts raw transactional information into
decision-oriented risk information.

---

## 9. Validation and Reconciliation

Analytical results are validated before being used in Power BI.

Reconciliation checks compare key exposure measures and portfolio totals to
ensure that the final analytical dataset is internally consistent.

This stage helps identify calculation errors, missing records, inconsistent
joins, or unexpected changes in exposure values.

---

## 10. Final Power BI Dataset

After SQL analysis and validation, the final analytical dataset is exported
for Power BI reporting.

The final dataset contains trade-level risk information required by the
dashboard, including:

- Trade ID
- Trade status
- Financial exposure
- FX exposure
- Combined exposure
- Hedge status
- Hedge type
- Risk priority
- Risk rank
- Management action

The exported dataset provides a stable reporting layer between SQL analysis
and Power BI.

---

## 11. Power BI Reporting

The final dataset is imported into Power BI to create management-focused
reports.

The dashboard presents:

- Executive risk KPIs
- Risk priority distribution
- Exposure by risk priority
- Management action distribution
- Hedge-related exposure
- Trade-level risk details
- Management decision queues

Power BI provides the visual reporting layer for the analytical results.

---

## 12. Management Decision Support

The final output is designed to support management decisions rather than
simply display data.

The dashboard helps management identify:

- Highest-risk trades
- Significant financial exposure
- Significant FX exposure
- Trades requiring immediate intervention
- Trades requiring management review
- Trades requiring monitoring

This connects the analytical workflow to practical business decision-making.

---

## 13. Pipeline Principle

The EastBridge pipeline follows a controlled progression:

```text
Source Data
|
Validate
|
Process
|
Store
|
Analyse
|
Reconcile
|
Report
|
Decide
```

Each stage has a defined purpose and provides the foundation for the next
stage.

The objective is to maintain traceability from source transaction data to
final management decisions.