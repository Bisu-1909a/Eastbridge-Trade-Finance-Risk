-- ============================================================
-- 42_top_risk_concentration.sql
-- EastBridge Trade Finance Risk & Margin Leakage Intelligence
--
-- Purpose:
-- Measure how much total combined exposure is concentrated
-- in the highest-risk individual trades.
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

ranked_risk AS (

    SELECT
        trade_id,
        combined_exposure,

        ROW_NUMBER() OVER (
            ORDER BY combined_exposure DESC
        ) AS risk_rank

    FROM combined_risk

),

concentration AS (

    SELECT
        'TOP 5' AS concentration_group,
        1 AS sort_order,
        COUNT(*) AS trade_count,
        ROUND(SUM(combined_exposure), 2) AS combined_exposure,
        ROUND(
            SUM(combined_exposure) * 100.0
            /
            (SELECT SUM(combined_exposure)
             FROM ranked_risk),
            2
        ) AS exposure_percentage

    FROM ranked_risk

    WHERE risk_rank <= 5

    UNION ALL

    SELECT
        'TOP 10',
        2,
        COUNT(*),
        ROUND(SUM(combined_exposure), 2),
        ROUND(
            SUM(combined_exposure) * 100.0
            /
            (SELECT SUM(combined_exposure)
             FROM ranked_risk),
            2
        )

    FROM ranked_risk

    WHERE risk_rank <= 10

    UNION ALL

    SELECT
        'TOP 20',
        3,
        COUNT(*),
        ROUND(SUM(combined_exposure), 2),
        ROUND(
            SUM(combined_exposure) * 100.0
            /
            (SELECT SUM(combined_exposure)
             FROM ranked_risk),
            2
        )

    FROM ranked_risk

    WHERE risk_rank <= 20

)

SELECT
    concentration_group,
    trade_count,
    combined_exposure,
    exposure_percentage

FROM concentration

ORDER BY sort_order;