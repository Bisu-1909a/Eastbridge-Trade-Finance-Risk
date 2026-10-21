-- ============================================================
-- EastBridge Trade Finance Risk & Margin Leakage Intelligence
-- Canonical Trade Risk Dataset
--
-- Grain: 1 row per trade
--
-- Definitions:
-- Financial Exposure = Outstanding customer receivable
-- FX Exposure        = Unhedged FX exposure
-- Combined Exposure  = Financial Exposure + Unhedged FX Exposure
-- Expected Profit    = Expected Revenue - Procurement - Operational
--
-- Risk thresholds are internal analytical assumptions for this
-- synthetic case study and are not regulatory thresholds.
-- ============================================================

WITH payment_summary AS (
    SELECT
        i.trade_id,
        SUM(i.invoice_amount) AS invoice_amount,
        SUM(COALESCE(p.payment_amount, 0)) AS payment_amount
    FROM invoice i
    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id
    GROUP BY
        i.trade_id
),

financial_risk AS (
    SELECT
        trade_id,
        ROUND(
            invoice_amount - payment_amount,
            2
        ) AS financial_exposure
    FROM payment_summary
),

hedge_summary AS (
    SELECT
        fx.trade_id,
        SUM(fx.exposure_amount) AS fx_exposure,
        SUM(COALESCE(h.hedged_amount, 0)) AS hedged_amount
    FROM fx_exposure fx
    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id
    GROUP BY
        fx.trade_id
),

fx_risk AS (
    SELECT
        trade_id,

        ROUND(
            fx_exposure,
            2
        ) AS fx_exposure,

        ROUND(
            hedged_amount,
            2
        ) AS hedged_amount,

        ROUND(
            MAX(fx_exposure - hedged_amount, 0),
            2
        ) AS unhedged_fx_exposure

    FROM hedge_summary
),

shipment_risk AS (
    SELECT
        trade_id,

        shipment_status,

        expected_arrival_date,

        actual_arrival_date,

        CASE
            WHEN actual_arrival_date IS NOT NULL
             AND expected_arrival_date IS NOT NULL
            THEN
                CAST(
                    julianday(actual_arrival_date)
                    - julianday(expected_arrival_date)
                    AS INTEGER
                )
            ELSE NULL
        END AS shipment_delay_days

    FROM shipment
),

trade_risk AS (
    SELECT
        t.trade_id,
        t.trade_status,
        t.trade_date,
        c.currency_code AS currency,

        t.expected_revenue,
        t.expected_procurement_cost,
        t.expected_operational_cost,

        ROUND(
            t.expected_revenue
            - t.expected_procurement_cost
            - t.expected_operational_cost,
            2
        ) AS expected_profit,

        COALESCE(
            f.financial_exposure,
            0
        ) AS financial_exposure,

        COALESCE(
            x.fx_exposure,
            0
        ) AS fx_exposure,

        COALESCE(
            x.hedged_amount,
            0
        ) AS hedged_amount,

        COALESCE(
            x.unhedged_fx_exposure,
            0
        ) AS unhedged_fx_exposure,

        ROUND(
            COALESCE(f.financial_exposure, 0)
            +
            COALESCE(x.unhedged_fx_exposure, 0),
            2
        ) AS combined_exposure,

        s.shipment_status,
        s.expected_arrival_date,
        s.actual_arrival_date,
        s.shipment_delay_days

    FROM trade t

    LEFT JOIN currency c
        ON t.currency_id = c.currency_id

    LEFT JOIN financial_risk f
        ON t.trade_id = f.trade_id

    LEFT JOIN fx_risk x
        ON t.trade_id = x.trade_id

    LEFT JOIN shipment_risk s
        ON t.trade_id = s.trade_id
)

SELECT
    *,

    CASE
        WHEN combined_exposure >= 120000
            THEN 'CRITICAL'

        WHEN combined_exposure >= 90000
            THEN 'HIGH'

        WHEN combined_exposure >= 60000
            THEN 'MEDIUM'

        ELSE 'LOW'
    END AS risk_priority,

    CASE
        WHEN combined_exposure >= 120000
            THEN 'Immediate management intervention'

        WHEN combined_exposure >= 90000
            THEN 'Management review required'

        WHEN combined_exposure >= 60000
            THEN 'Monitor and review'

        ELSE 'Routine monitoring'
    END AS management_action

FROM trade_risk

ORDER BY
    combined_exposure DESC;