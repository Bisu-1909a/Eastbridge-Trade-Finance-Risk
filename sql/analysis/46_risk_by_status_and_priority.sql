-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 46 — Risk by Trade Status and Priority
--
-- Purpose:
-- Show combined financial + unhedged FX risk across both
-- trade lifecycle status and management priority.
--
-- Grain:
-- 1 row per trade status + risk priority
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

        t.trade_status,

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
),

prioritized_risk AS (

    SELECT

        trade_id,

        trade_status,

        financial_exposure,

        unhedged_fx_exposure,

        combined_exposure,

        CASE

            WHEN combined_exposure >= 120000
                THEN 'CRITICAL'

            WHEN combined_exposure >= 90000
                THEN 'HIGH'

            WHEN combined_exposure >= 60000
                THEN 'MEDIUM'

            ELSE 'LOW'

        END AS risk_priority

    FROM combined_risk
)

SELECT

    trade_status,

    risk_priority,

    COUNT(*) AS trade_count,

    ROUND(
        SUM(financial_exposure),
        2
    ) AS financial_exposure,

    ROUND(
        SUM(unhedged_fx_exposure),
        2
    ) AS unhedged_fx_exposure,

    ROUND(
        SUM(combined_exposure),
        2
    ) AS combined_exposure,

    ROUND(
        AVG(combined_exposure),
        2
    ) AS average_exposure

FROM prioritized_risk

GROUP BY
    trade_status,
    risk_priority

ORDER BY

    CASE risk_priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END,

    combined_exposure DESC;