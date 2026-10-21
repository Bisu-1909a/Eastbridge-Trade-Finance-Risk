-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 50 — Final Management Decision Queue
--
-- Purpose:
-- Create the final executive-level decision dataset for
-- EastBridge management.
--
-- This combines:
--   1. Financial exposure
--   2. Unhedged FX exposure
--   3. Combined exposure
--   4. Trade lifecycle status
--   5. Hedge status
--   6. Management priority
--   7. Management action
--   8. Risk rank
--
-- Grain:
-- 1 row per trade requiring management attention
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
        ) AS hedged_amount,

        MAX(
            h.hedge_status
        ) AS hedge_status

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
        ) AS unhedged_fx_exposure,

        COALESCE(
            hedge_status,
            'NO_HEDGE'
        ) AS hedge_status

    FROM hedge_summary

    GROUP BY
        trade_id,
        hedge_status
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

        COALESCE(
            x.hedge_status,
            'NO_HEDGE'
        ) AS hedge_status,

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

ranked_risk AS (

    SELECT

        *,

        ROW_NUMBER() OVER (
            ORDER BY
                combined_exposure DESC,
                trade_id
        ) AS risk_rank

    FROM combined_risk
),

prioritized_risk AS (

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

        END AS risk_priority

    FROM ranked_risk
)

SELECT

    trade_id,

    trade_status,

    ROUND(
        financial_exposure,
        2
    ) AS financial_exposure,

    ROUND(
        unhedged_fx_exposure,
        2
    ) AS fx_exposure,

    ROUND(
        combined_exposure,
        2
    ) AS combined_exposure,

    hedge_status,

    risk_priority,

    risk_rank,

    CASE

        WHEN risk_priority = 'CRITICAL'
            THEN 'Immediate management intervention'

        WHEN risk_priority = 'HIGH'
            THEN 'Management review required'

        WHEN risk_priority = 'MEDIUM'
            THEN 'Monitor and review'

        ELSE
            'Routine monitoring'

    END AS management_action

FROM prioritized_risk

WHERE
    risk_priority IN (
        'CRITICAL',
        'HIGH',
        'MEDIUM'
    )

ORDER BY
    risk_rank;