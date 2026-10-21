-- ============================================================
-- 18 - FX Risk Priority Summary
-- ============================================================

WITH risk_classification AS (

    SELECT
        fx.trade_id,

        fx.exposure_amount
            - h.hedged_amount AS unhedged_exposure,

        CASE
            WHEN fx.exposure_amount - h.hedged_amount >= 30000
                THEN 'CRITICAL'

            WHEN fx.exposure_amount - h.hedged_amount >= 20000
                THEN 'HIGH'

            WHEN fx.exposure_amount - h.hedged_amount >= 10000
                THEN 'MEDIUM'

            ELSE 'LOW'
        END AS risk_priority

    FROM fx_exposure fx

    JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id
)

SELECT
    risk_priority,

    COUNT(*) AS trade_count,

    ROUND(
        SUM(unhedged_exposure),
        2
    ) AS total_unhedged_exposure,

    ROUND(
        AVG(unhedged_exposure),
        2
    ) AS average_unhedged_exposure

FROM risk_classification

GROUP BY
    risk_priority

ORDER BY
    CASE risk_priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END;