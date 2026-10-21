-- Mission 51
-- Executive Decision Summary
-- Purpose:
-- Provide management with a compact summary of the final decision queue,
-- grouped by management action and risk priority.

WITH final_queue AS (
    SELECT
        trade_id,
        combined_risk,
        fx_risk,
        total_risk,
        hedge_status,
        risk_priority,
        management_action
    FROM (
        SELECT
            trade_id,
            financial_risk AS combined_risk,
            fx_risk,
            (financial_risk + fx_risk) AS total_risk,
            hedge_status,
            risk_priority,
            CASE
                WHEN risk_priority = 'CRITICAL'
                    THEN 'Immediate management intervention'
                WHEN risk_priority = 'HIGH'
                    THEN 'Management review required'
                WHEN risk_priority = 'MEDIUM'
                    THEN 'Monitor and review'
                ELSE 'Routine monitoring'
            END AS management_action
        FROM (
            SELECT
                trade.trade_id,

                (
                    trade.expected_revenue
                    - trade.expected_procurement_cost
                    - trade.expected_operational_cost
                ) AS financial_risk,

                COALESCE(
                    fx.exposure_amount - COALESCE(h.hedged_amount, 0),
                    0
                ) AS fx_risk,

                CASE
                    WHEN
                        (
                            trade.expected_revenue
                            - trade.expected_procurement_cost
                            - trade.expected_operational_cost
                        )
                        +
                        COALESCE(
                            fx.exposure_amount - COALESCE(h.hedged_amount, 0),
                            0
                        ) >= 120000
                        THEN 'CRITICAL'

                    WHEN
                        (
                            trade.expected_revenue
                            - trade.expected_procurement_cost
                            - trade.expected_operational_cost
                        )
                        +
                        COALESCE(
                            fx.exposure_amount - COALESCE(h.hedged_amount, 0),
                            0
                        ) >= 90000
                        THEN 'HIGH'

                    WHEN
                        (
                            trade.expected_revenue
                            - trade.expected_procurement_cost
                            - trade.expected_operational_cost
                        )
                        +
                        COALESCE(
                            fx.exposure_amount - COALESCE(h.hedged_amount, 0),
                            0
                        ) >= 30000
                        THEN 'MEDIUM'

                    ELSE 'LOW'
                END AS risk_priority,

                h.hedge_status

            FROM trade

            LEFT JOIN fx_exposure fx
                ON trade.trade_id = fx.trade_id

            LEFT JOIN hedge h
                ON fx.fx_exposure_id = h.fx_exposure_id
        )
    )
)

SELECT
    management_action,
    risk_priority,
    COUNT(*) AS trade_count,
    ROUND(SUM(combined_risk), 2) AS financial_risk,
    ROUND(SUM(fx_risk), 2) AS fx_risk,
    ROUND(SUM(total_risk), 2) AS total_risk,
    ROUND(AVG(total_risk), 2) AS avg_total_risk
FROM final_queue
GROUP BY
    management_action,
    risk_priority
ORDER BY
    CASE risk_priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END;