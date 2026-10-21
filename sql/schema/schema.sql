-- ============================================================
-- EastBridge Trade Finance Risk
-- Database Schema
-- SQLite
-- ============================================================

PRAGMA foreign_keys = ON;


-- ============================================================
-- 1. MASTER / REFERENCE TABLES
-- ============================================================

CREATE TABLE country (
    country_id INTEGER PRIMARY KEY,
    country_code TEXT NOT NULL UNIQUE,
    country_name TEXT NOT NULL
);


CREATE TABLE currency (
    currency_id INTEGER PRIMARY KEY,
    currency_code TEXT NOT NULL UNIQUE,
    currency_name TEXT NOT NULL
);


CREATE TABLE customer (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    country_id INTEGER NOT NULL,
    industry TEXT,
    customer_segment TEXT,

    FOREIGN KEY (country_id)
        REFERENCES country(country_id)
);


CREATE TABLE supplier (
    supplier_id INTEGER PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    country_id INTEGER NOT NULL,
    supplier_type TEXT,

    FOREIGN KEY (country_id)
        REFERENCES country(country_id)
);


CREATE TABLE product (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    product_category TEXT NOT NULL
);


CREATE TABLE route (
    route_id INTEGER PRIMARY KEY,
    origin_country_id INTEGER NOT NULL,
    destination_country_id INTEGER NOT NULL,
    route_name TEXT NOT NULL,

    FOREIGN KEY (origin_country_id)
        REFERENCES country(country_id),

    FOREIGN KEY (destination_country_id)
        REFERENCES country(country_id)
);


-- ============================================================
-- 2. CORE BUSINESS TABLE
-- ============================================================

CREATE TABLE trade (
    trade_id INTEGER PRIMARY KEY,

    customer_id INTEGER NOT NULL,
    supplier_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    route_id INTEGER NOT NULL,
    currency_id INTEGER NOT NULL,

    trade_date TEXT NOT NULL,
    trade_status TEXT NOT NULL,

    expected_revenue NUMERIC,
    expected_procurement_cost NUMERIC,
    expected_operational_cost NUMERIC,

    expected_shipment_date TEXT,
    expected_payment_date TEXT,

    FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),

    FOREIGN KEY (supplier_id)
        REFERENCES supplier(supplier_id),

    FOREIGN KEY (product_id)
        REFERENCES product(product_id),

    FOREIGN KEY (route_id)
        REFERENCES route(route_id),

    FOREIGN KEY (currency_id)
        REFERENCES currency(currency_id)
);


-- ============================================================
-- 3. FINANCIAL TABLES
-- ============================================================

CREATE TABLE invoice (
    invoice_id INTEGER PRIMARY KEY,

    trade_id INTEGER NOT NULL,
    invoice_number TEXT NOT NULL,
    invoice_date TEXT NOT NULL,
    due_date TEXT,

    invoice_amount NUMERIC,
    currency_id INTEGER NOT NULL,
    invoice_status TEXT,

    FOREIGN KEY (trade_id)
        REFERENCES trade(trade_id),

    FOREIGN KEY (currency_id)
        REFERENCES currency(currency_id)
);


CREATE TABLE payment (
    payment_id INTEGER PRIMARY KEY,

    invoice_id INTEGER NOT NULL,
    payment_date TEXT NOT NULL,
    payment_amount NUMERIC,

    currency_id INTEGER NOT NULL,
    payment_method TEXT,
    payment_status TEXT,

    FOREIGN KEY (invoice_id)
        REFERENCES invoice(invoice_id),

    FOREIGN KEY (currency_id)
        REFERENCES currency(currency_id)
);


CREATE TABLE financial_event (
    financial_event_id INTEGER PRIMARY KEY,

    trade_id INTEGER NOT NULL,
    event_type TEXT NOT NULL,
    event_date TEXT NOT NULL,

    amount NUMERIC,
    currency_id INTEGER NOT NULL,
    description TEXT,

    FOREIGN KEY (trade_id)
        REFERENCES trade(trade_id),

    FOREIGN KEY (currency_id)
        REFERENCES currency(currency_id)
);


-- ============================================================
-- 4. OPERATIONAL TABLES
-- ============================================================

CREATE TABLE shipment (
    shipment_id INTEGER PRIMARY KEY,

    trade_id INTEGER NOT NULL,
    shipment_date TEXT,
    expected_arrival_date TEXT,
    actual_arrival_date TEXT,
    shipment_status TEXT,

    FOREIGN KEY (trade_id)
        REFERENCES trade(trade_id)
);


CREATE TABLE operational_event (
    operational_event_id INTEGER PRIMARY KEY,

    shipment_id INTEGER NOT NULL,
    event_type TEXT NOT NULL,
    event_date TEXT NOT NULL,
    event_description TEXT,

    FOREIGN KEY (shipment_id)
        REFERENCES shipment(shipment_id)
);


-- ============================================================
-- 5. FOREIGN EXCHANGE TABLES
-- ============================================================

CREATE TABLE fx_exposure (
    fx_exposure_id INTEGER PRIMARY KEY,

    trade_id INTEGER NOT NULL,
    currency_id INTEGER NOT NULL,

    exposure_direction TEXT,
    exposure_amount NUMERIC,

    exposure_start_date TEXT,
    expected_settlement_date TEXT,

    FOREIGN KEY (trade_id)
        REFERENCES trade(trade_id),

    FOREIGN KEY (currency_id)
        REFERENCES currency(currency_id)
);


CREATE TABLE fx_rate (
    fx_rate_id INTEGER PRIMARY KEY,

    currency_id INTEGER NOT NULL,
    rate_date TEXT NOT NULL,
    exchange_rate NUMERIC,

    FOREIGN KEY (currency_id)
        REFERENCES currency(currency_id)
);


CREATE TABLE hedge (
    hedge_id INTEGER PRIMARY KEY,

    fx_exposure_id INTEGER NOT NULL,

    hedge_date TEXT,
    hedge_type TEXT,
    hedged_amount NUMERIC,
    hedge_rate NUMERIC,
    hedge_status TEXT,

    FOREIGN KEY (fx_exposure_id)
        REFERENCES fx_exposure(fx_exposure_id)
);

