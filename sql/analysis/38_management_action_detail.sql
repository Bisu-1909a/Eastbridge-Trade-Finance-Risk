-- Mission 38: Management Action Detail
-- Purpose:
-- Create a detailed management action queue by combining
-- outstanding financial exposure, FX exposure, and risk priority.
--
-- Output:
-- trade_id
-- outstanding_exposure
-- fx_unhedged_exposure
-- combined_exposure
-- priority
-- management_action

WITH financial_risk AS (
    SELECT
        trade_id,
        outstanding AS outstanding_exposure
    FROM (
        SELECT
            i.trade_id,
            i.invoice_amount - COALESCE(p.payment_amount, 0) AS outstanding
        FROM invoice i
        LEFT JOIN payment p
            ON i.invoice_id = p.invoice_id
    ) AS invoice_balance
    WHERE outstanding > 0
),

fx_risk AS (
    SELECT
        fx.trade_id,
        fx.exposure_amount,
        COALESCE(h.hedged_amount, 0) AS hedged_amount,
        fx.exposure_amount - COALESCE(h.hedged_amount, 0)
            AS unhedged_fx_exposure
    FROM fx_exposure fx
    LEFT JOIN (
        SELECT
            fx_exposure_id,
            SUM(hedged_amount) AS hedged_amount
        FROM hedge
        GROUP BY fx_exposure_id
    ) h
        ON fx.fx_exposure_id = h.fx_exposure_id
),

combined AS (
    SELECT
        f.trade_id,
        f.outstanding_exposure,
        COALESCE(x.unhedged_fx_exposure, 0) AS unhedged_fx_exposure,
        f.outstanding_exposure
            + COALESCE(x.unhedged_fx_exposure, 0) AS combined_exposure
    FROM financial_risk f
    LEFT JOIN fx_risk x
        ON f.trade_id = x.trade_id
),

prioritized AS (
    SELECT
        trade_id,
        outstanding_exposure,
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
        END AS priority
    FROM combined
)

SELECT
    trade_id,
    ROUND(outstanding_exposure, 2) AS outstanding_exposure,
    ROUND(unhedged_fx_exposure, 2) AS unhedged_fx_exposure,
    ROUND(combined_exposure, 2) AS combined_exposure,
    priority,
    CASE
        WHEN priority = 'CRITICAL'
            THEN 'Immediate management intervention'
        WHEN priority = 'HIGH'
            THEN 'Management review required'
        WHEN priority = 'MEDIUM'
            THEN 'Monitor and review'
        ELSE 'Routine monitoring'
    END AS management_action
FROM prioritized
WHERE priority IN ('CRITICAL', 'HIGH')
ORDER BY
    CASE priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        ELSE 4
    END,
    combined_exposure DESC;