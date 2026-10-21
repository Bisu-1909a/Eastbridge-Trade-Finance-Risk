-- Mission 52
-- Management Action by Trade Status
-- Purpose:
-- Show where management attention is concentrated across trade lifecycle status.

WITH risk_data AS (
    SELECT
        t.trade_id,
        t.trade_status,

        (
            t.expected_revenue
            - t.expected_procurement_cost
            - t.expected_operational_cost
        ) AS financial_risk,

        COALESCE(
            fx.exposure_amount - COALESCE(h.hedged_amount, 0),
            0
        ) AS fx_risk

    FROM trade t

    LEFT JOIN fx_exposure fx
        ON t.trade_id = fx.trade_id

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id
),

scored AS (
    SELECT
        trade_id,
        trade_status,
        financial_risk,
        fx_risk,
        financial_risk + fx_risk AS total_risk,

        CASE
            WHEN financial_risk + fx_risk >= 120000
                THEN 'CRITICAL'
            WHEN financial_risk + fx_risk >= 90000
                THEN 'HIGH'
            WHEN financial_risk + fx_risk >= 30000
                THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_priority

    FROM risk_data
)

SELECT
    trade_status,
    risk_priority,
    COUNT(*) AS trade_count,
    ROUND(SUM(financial_risk), 2) AS financial_risk,
    ROUND(SUM(fx_risk), 2) AS fx_risk,
    ROUND(SUM(total_risk), 2) AS total_risk,
    ROUND(AVG(total_risk), 2) AS avg_total_risk

FROM scored

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
    total_risk DESC;