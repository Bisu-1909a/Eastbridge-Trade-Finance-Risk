-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 57 — Final Executive Validation
--
-- Purpose:
-- Validate the core executive risk calculations before
-- moving the analysis into Power BI.
--
-- Checks:
--   1. Total trade count
--   2. Total financial exposure
--   3. Total FX exposure
--   4. Total combined exposure
--   5. Risk priority distribution
--   6. Exposure concentration
-- ============================================================

WITH financial_risk AS (

    SELECT
        trade_id,

        expected_revenue
        - expected_procurement_cost
        - expected_operational_cost
            AS financial_exposure

    FROM trade
),

fx_risk AS (

    SELECT
        fx.trade_id,

        SUM(
            fx.exposure_amount
            - COALESCE(h.hedged_amount, 0)
        ) AS fx_exposure

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    GROUP BY
        fx.trade_id
),

combined_risk AS (

    SELECT

        t.trade_id,

        COALESCE(
            fr.financial_exposure,
            0
        ) AS financial_exposure,

        COALESCE(
            fxr.fx_exposure,
            0
        ) AS fx_exposure,

        COALESCE(
            fr.financial_exposure,
            0
        )
        +
        COALESCE(
            fxr.fx_exposure,
            0
        ) AS combined_risk

    FROM trade t

    LEFT JOIN financial_risk fr
        ON t.trade_id = fr.trade_id

    LEFT JOIN fx_risk fxr
        ON t.trade_id = fxr.trade_id
),

validated AS (

    SELECT

        trade_id,
        financial_exposure,
        fx_exposure,
        combined_risk,

        CASE
            WHEN combined_risk >= 110000
                THEN 'CRITICAL'

            WHEN combined_risk >= 80000
                THEN 'HIGH'

            WHEN combined_risk >= 50000
                THEN 'MEDIUM'

            ELSE 'LOW'
        END AS risk_priority

    FROM combined_risk
)

SELECT
    'TOTAL TRADES' AS validation_metric,
    COUNT(*) AS value
FROM validated

UNION ALL

SELECT
    'TOTAL FINANCIAL EXPOSURE',
    ROUND(SUM(financial_exposure), 2)
FROM validated

UNION ALL

SELECT
    'TOTAL FX EXPOSURE',
    ROUND(SUM(fx_exposure), 2)
FROM validated

UNION ALL

SELECT
    'TOTAL COMBINED EXPOSURE',
    ROUND(SUM(combined_risk), 2)
FROM validated

UNION ALL

SELECT
    'CRITICAL TRADES',
    COUNT(*)
FROM validated
WHERE risk_priority = 'CRITICAL'

UNION ALL

SELECT
    'HIGH TRADES',
    COUNT(*)
FROM validated
WHERE risk_priority = 'HIGH'

UNION ALL

SELECT
    'MEDIUM TRADES',
    COUNT(*)
FROM validated
WHERE risk_priority = 'MEDIUM'

UNION ALL

SELECT
    'LOW TRADES',
    COUNT(*)
FROM validated
WHERE risk_priority = 'LOW'

UNION ALL

SELECT
    'TOP 5 RISK',
    ROUND(
        (
            SELECT SUM(combined_risk)
            FROM (
                SELECT combined_risk
                FROM validated
                ORDER BY combined_risk DESC
                LIMIT 5
            )
        ),
        2
    )

UNION ALL

SELECT
    'TOP 10 RISK',
    ROUND(
        (
            SELECT SUM(combined_risk)
            FROM (
                SELECT combined_risk
                FROM validated
                ORDER BY combined_risk DESC
                LIMIT 10
            )
        ),
        2
    )

UNION ALL

SELECT
    'TOP 20 RISK',
    ROUND(
        (
            SELECT SUM(combined_risk)
            FROM (
                SELECT combined_risk
                FROM validated
                ORDER BY combined_risk DESC
                LIMIT 20
            )
        ),
        2
    );