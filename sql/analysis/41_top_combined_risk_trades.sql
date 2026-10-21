-- ============================================================
-- 41_top_combined_risk_trades.sql
-- EastBridge Trade Finance Risk & Margin Leakage Intelligence
--
-- Purpose:
-- Identify the individual trades carrying the largest
-- combined financial + FX exposure.
-- ============================================================

WITH combined_risk AS (

    SELECT
        t.trade_id,

        ROUND(
            t.expected_revenue
            - COALESCE(inv.total_paid, 0),
            2
        ) AS financial_exposure,

        ROUND(
            COALESCE(fx.unhedged_exposure, 0),
            2
        ) AS fx_exposure,

        ROUND(
            (
                t.expected_revenue
                - COALESCE(inv.total_paid, 0)
            )
            + COALESCE(fx.unhedged_exposure, 0),
            2
        ) AS combined_exposure

    FROM trade t

    LEFT JOIN (

        SELECT
            i.trade_id,
            SUM(COALESCE(p.payment_amount, 0)) AS total_paid

        FROM invoice i

        LEFT JOIN payment p
            ON i.invoice_id = p.invoice_id

        GROUP BY i.trade_id

    ) inv
        ON t.trade_id = inv.trade_id

    LEFT JOIN (

        SELECT
            fx.trade_id,

            SUM(
                fx.exposure_amount
                - COALESCE(h.hedged_amount, 0)
            ) AS unhedged_exposure

        FROM fx_exposure fx

        LEFT JOIN hedge h
            ON fx.fx_exposure_id = h.fx_exposure_id

        GROUP BY fx.trade_id

    ) fx
        ON t.trade_id = fx.trade_id

),

priority_classification AS (

    SELECT
        trade_id,
        financial_exposure,
        fx_exposure,
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
    trade_id,
    financial_exposure,
    fx_exposure,
    combined_exposure,
    risk_priority,

    ROUND(
        combined_exposure * 100.0
        /
        (
            SELECT SUM(combined_exposure)
            FROM priority_classification
        ),
        2
    ) AS exposure_percentage

FROM priority_classification

ORDER BY
    combined_exposure DESC

LIMIT 20;