-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 44 — Executive Risk by Currency
--
-- Purpose:
-- Identify which currencies carry the largest combined
-- financial + unhedged FX risk exposure.
--
-- Grain:
-- 1 row per currency
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
        ) AS unhedged_fx_exposure

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    GROUP BY
        fx.trade_id,
        fx.currency_id
),

combined_risk AS (

    SELECT

        f.trade_id,
        f.currency_id,

        f.financial_exposure,

        COALESCE(
            x.unhedged_fx_exposure,
            0
        ) AS unhedged_fx_exposure,

        f.financial_exposure
        +
        COALESCE(
            x.unhedged_fx_exposure,
            0
        ) AS combined_exposure

    FROM financial_risk f

    LEFT JOIN fx_risk x
        ON f.trade_id = x.trade_id
        AND f.currency_id = x.currency_id
),

currency_summary AS (

    SELECT

        currency_id,

        COUNT(*) AS trade_count,

        SUM(financial_exposure)
            AS financial_exposure,

        SUM(unhedged_fx_exposure)
            AS unhedged_fx_exposure,

        SUM(combined_exposure)
            AS combined_exposure

    FROM combined_risk

    GROUP BY
        currency_id
),

portfolio_total AS (

    SELECT
        SUM(combined_exposure)
            AS total_combined_exposure

    FROM currency_summary
)

SELECT

    currency_id,

    trade_count,

    ROUND(
        financial_exposure,
        2
    ) AS financial_exposure,

    ROUND(
        unhedged_fx_exposure,
        2
    ) AS unhedged_fx_exposure,

    ROUND(
        combined_exposure,
        2
    ) AS combined_exposure,

    ROUND(
        100.0
        * combined_exposure
        / NULLIF(
            total_combined_exposure,
            0
        ),
        2
    ) AS risk_share_percentage,

    ROUND(
        combined_exposure
        / NULLIF(trade_count, 0),
        2
    ) AS average_risk_per_trade

FROM currency_summary

CROSS JOIN portfolio_total

ORDER BY
    combined_exposure DESC;