-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 48 — Executive Dashboard KPI Dataset
--
-- Purpose:
-- Produce the core KPIs required for the EastBridge
-- Trade Finance Risk & Margin Leakage executive dashboard.
--
-- Grain:
-- 1 row — executive portfolio summary
--
-- Definitions:
-- Financial Exposure = Outstanding customer receivable
-- FX Exposure        = Unhedged FX exposure
-- Combined Exposure  = Financial + Unhedged FX
--
-- Risk thresholds:
-- CRITICAL >= 120,000
-- HIGH     >= 90,000
-- MEDIUM   >= 60,000
-- LOW      < 60,000
-- ============================================================

WITH payment_summary AS (

    SELECT
        i.trade_id,

        SUM(i.invoice_amount) AS invoice_amount,

        SUM(
            COALESCE(p.payment_amount, 0)
        ) AS payment_amount

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

    WHERE
        invoice_amount - payment_amount > 0
),

hedge_summary AS (

    SELECT
        fx.trade_id,

        SUM(
            fx.exposure_amount
        ) AS fx_exposure,

        SUM(
            COALESCE(h.hedged_amount, 0)
        ) AS hedged_amount

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
            MAX(
                fx_exposure - hedged_amount,
                0
            ),
            2
        ) AS unhedged_fx_exposure

    FROM hedge_summary

    GROUP BY
        trade_id
),

combined_risk AS (

    SELECT

        t.trade_id,

        COALESCE(
            f.financial_exposure,
            0
        ) AS financial_exposure,

        COALESCE(
            x.unhedged_fx_exposure,
            0
        ) AS unhedged_fx_exposure,

        ROUND(
            COALESCE(
                f.financial_exposure,
                0
            )
            +
            COALESCE(
                x.unhedged_fx_exposure,
                0
            ),
            2
        ) AS combined_exposure

    FROM trade t

    LEFT JOIN financial_risk f
        ON t.trade_id = f.trade_id

    LEFT JOIN fx_risk x
        ON t.trade_id = x.trade_id
)

SELECT

    COUNT(*) AS total_trades,

    ROUND(
        SUM(financial_exposure),
        2
    ) AS total_financial_exposure,

    ROUND(
        SUM(unhedged_fx_exposure),
        2
    ) AS total_fx_exposure,

    ROUND(
        SUM(combined_exposure),
        2
    ) AS total_combined_exposure,

    ROUND(
        AVG(combined_exposure),
        2
    ) AS average_combined_exposure,

    ROUND(
        MAX(combined_exposure),
        2
    ) AS highest_trade_risk,

    SUM(
        CASE
            WHEN combined_exposure >= 120000
            THEN 1
            ELSE 0
        END
    ) AS critical_trade_count,

    ROUND(
        SUM(
            CASE
                WHEN combined_exposure >= 120000
                THEN combined_exposure
                ELSE 0
            END
        ),
        2
    ) AS critical_exposure,

    SUM(
        CASE
            WHEN combined_exposure >= 90000
             AND combined_exposure < 120000
            THEN 1
            ELSE 0
        END
    ) AS high_trade_count,

    ROUND(
        SUM(
            CASE
                WHEN combined_exposure >= 90000
                 AND combined_exposure < 120000
                THEN combined_exposure
                ELSE 0
            END
        ),
        2
    ) AS high_exposure,

    SUM(
        CASE
            WHEN combined_exposure >= 60000
             AND combined_exposure < 90000
            THEN 1
            ELSE 0
        END
    ) AS medium_trade_count,

    ROUND(
        SUM(
            CASE
                WHEN combined_exposure >= 60000
                 AND combined_exposure < 90000
                THEN combined_exposure
                ELSE 0
            END
        ),
        2
    ) AS medium_exposure,

    SUM(
        CASE
            WHEN combined_exposure < 60000
            THEN 1
            ELSE 0
        END
    ) AS low_trade_count,

    ROUND(
        SUM(
            CASE
                WHEN combined_exposure < 60000
                THEN combined_exposure
                ELSE 0
            END
        ),
        2
    ) AS low_exposure

FROM combined_risk;