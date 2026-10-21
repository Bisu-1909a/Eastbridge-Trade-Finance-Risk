import sqlite3
import pandas as pd

DB_PATH = "database/eastbridge.db"
OUTPUT_PATH = "data/powerbi_trade_risk_dataset.csv"

conn = sqlite3.connect(DB_PATH)

query = """
SELECT
    t.trade_id,
    t.trade_status,
    t.trade_date,

    c.currency_code AS currency,

    t.expected_revenue,
    t.expected_procurement_cost,
    t.expected_operational_cost,

    i.invoice_amount,
    i.invoice_status,

    p.payment_amount,
    p.payment_status,

    fe.amount AS financial_event_amount,

    fx.exposure_direction,
    fx.exposure_amount,

    h.hedged_amount,
    h.hedge_type,
    h.hedge_rate,
    h.hedge_status,

    s.shipment_status,
    s.expected_arrival_date,
    s.actual_arrival_date

FROM trade t

LEFT JOIN currency c
    ON t.currency_id = c.currency_id

LEFT JOIN invoice i
    ON t.trade_id = i.trade_id

LEFT JOIN payment p
    ON i.invoice_id = p.invoice_id

LEFT JOIN financial_event fe
    ON t.trade_id = fe.trade_id

LEFT JOIN fx_exposure fx
    ON t.trade_id = fx.trade_id

LEFT JOIN hedge h
    ON fx.fx_exposure_id = h.fx_exposure_id

LEFT JOIN shipment s
    ON t.trade_id = s.trade_id

ORDER BY t.trade_id;
"""

df = pd.read_sql_query(query, conn)

conn.close()

print("Rows:", len(df))
print(df.head())

print("\nColumns:")
print(*df.columns, sep="\n")

df.to_csv(OUTPUT_PATH, index=False)

print("\nPower BI dataset created successfully.")
