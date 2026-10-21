-- Mission 55
-- Executive Action by Hedge Type
-- Purpose:
-- Rank hedge types by combined financial + FX risk
-- to identify where management attention should be focused.

WITH fx_data AS (
    SELECT
        fx.trade_id,
        fx.exposure_amount,
        COALESCE(h.hedged_amount, 0) AS hedged_amount,
        COALESCE(h.hedge_type, 'UNHEDGED') AS hedge_type
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

        COALESCE(fx.hedge_type, 'UNHEDGED') AS hedge_type

    FROM trade t

    LEFT JOIN fx_data fx
        ON t.trade_id = fx.trade_id
),

summary AS (
    SELECT
        hedge_type,
        COUNT(*) AS trade_count,
        SUM(financial_risk) AS financial_risk,
        SUM(fx_risk) AS fx_risk,
        SUM(financial_risk + fx_risk) AS total_risk

    FROM risk_data

    GROUP BY hedge_type
)

SELECT
    hedge_type,
    trade_count,
    ROUND(financial_risk, 2) AS financial_risk,
    ROUND(fx_risk, 2) AS fx_risk,
    ROUND(total_risk, 2) AS total_risk,
    ROUND(
        100.0 * total_risk /
        SUM(total_risk) OVER (),
        2
    ) AS risk_share_pct,
    ROUND(
        total_risk / trade_count,
        2
    ) AS avg_risk_per_trade

FROM summary

ORDER BY
    total_risk DESC;