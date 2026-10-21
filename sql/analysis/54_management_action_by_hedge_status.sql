-- Mission 54
-- Management Action by Hedge Status
-- Purpose:
-- Identify where combined financial + FX risk is concentrated
-- across hedge lifecycle status.

WITH fx_data AS (
    SELECT
        fx.trade_id,
        fx.exposure_amount,
        COALESCE(h.hedged_amount, 0) AS hedged_amount,
        COALESCE(h.hedge_status, 'UNHEDGED') AS hedge_status
    FROM fx_exposure fx
    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id
),

risk_data AS (
    SELECT
        t.trade_id,

        (
            t.expected_revenue
            - t.expected_procurement_cost
            - t.expected_operational_cost
        ) AS financial_risk,

        COALESCE(
            fx.exposure_amount - fx.hedged_amount,
            0
        ) AS fx_risk,

        COALESCE(fx.hedge_status, 'UNHEDGED') AS hedge_status

    FROM trade t

    LEFT JOIN fx_data fx
        ON t.trade_id = fx.trade_id
),

scored AS (
    SELECT
        trade_id,
        financial_risk,
        fx_risk,
        financial_risk + fx_risk AS total_risk,
        hedge_status

    FROM risk_data
)

SELECT
    hedge_status,
    COUNT(*) AS trade_count,
    ROUND(SUM(financial_risk), 2) AS financial_risk,
    ROUND(SUM(fx_risk), 2) AS fx_risk,
    ROUND(SUM(total_risk), 2) AS total_risk,
    ROUND(AVG(total_risk), 2) AS avg_total_risk

FROM scored

GROUP BY
    hedge_status

ORDER BY
    total_risk DESC;