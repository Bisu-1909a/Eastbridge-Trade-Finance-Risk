-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 62 — Final Open Trade Risk Dataset
--
-- Purpose:
-- Create the authoritative trade-level dataset for the
-- executive Power BI dashboard.
--
-- Grain:
-- 1 row per trade with outstanding financial exposure
--
-- Definitions:
-- Financial Exposure = Outstanding customer receivable
-- FX Exposure        = Unhedged FX exposure
-- Combined Exposure  = Financial + Unhedged FX
-- ============================================================

WITH financial_risk AS (

    SELECT
        i.trade_id,
        i.currency_id,

        MAX(i.invoice_amount)
        - COALESCE(
            SUM(p.payment_amount),
            0
        ) AS financial_exposure

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    GROUP BY
        i.trade_id,
        i.currency_id

    HAVING
        financial_exposure > 0
),

fx_risk AS (

    SELECT
        fx.trade_id,
        fx.currency_id,

        SUM(
            fx.exposure_amount
            - COALESCE(h.hedged_amount, 0)
        ) AS fx_exposure

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    GROUP BY
        fx.trade_id,
        fx.currency_id
),

risk_dataset AS (

    SELECT

        f.trade_id,
        f.currency_id,

        f.financial_exposure,

        COALESCE(
            x.fx_exposure,
            0
        ) AS fx_exposure,

        f.financial_exposure
        +
        COALESCE(
            x.fx_exposure,
            0
        ) AS combined_exposure

    FROM financial_risk f

    LEFT JOIN fx_risk x
        ON f.trade_id = x.trade_id
        AND f.currency_id = x.currency_id
)

SELECT

    trade_id,

    currency_id,

    ROUND(
        financial_exposure,
        2
    ) AS financial_exposure,

    ROUND(
        fx_exposure,
        2
    ) AS fx_exposure,

    ROUND(
        combined_exposure,
        2
    ) AS combined_exposure,

    CASE
        WHEN combined_exposure >= 120000
            THEN 'CRITICAL'

        WHEN combined_exposure >= 90000
            THEN 'HIGH'

        WHEN combined_exposure >= 30000
            THEN 'MEDIUM'

        ELSE 'LOW'
    END AS risk_priority

FROM risk_dataset

ORDER BY
    combined_exposure DESC;