-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 59 — Executive Risk Validation
--
-- Purpose:
-- Validate the final executive exposure model using:
--
--   Financial Exposure = Outstanding customer receivable
--   FX Exposure        = Unhedged FX exposure
--   Combined Exposure  = Financial + Unhedged FX
--
-- This definition is aligned with the executive analysis
-- used in Missions 44–56.
-- ============================================================

WITH financial_risk AS (

    SELECT
        i.trade_id,
        i.currency_id,

        MAX(i.invoice_amount)
        - COALESCE(
            SUM(p.payment_amount),
            0
        ) AS financial_exposure

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    GROUP BY
        i.trade_id,
        i.currency_id

    HAVING
        financial_exposure > 0
),

fx_risk AS (

    SELECT
        fx.trade_id,
        fx.currency_id,

        SUM(
            fx.exposure_amount
            - COALESCE(h.hedged_amount, 0)
        ) AS fx_exposure

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    GROUP BY
        fx.trade_id,
        fx.currency_id
),

combined_risk AS (

    SELECT

        f.trade_id,

        f.financial_exposure,

        COALESCE(
            x.fx_exposure,
            0
        ) AS fx_exposure,

        f.financial_exposure
        +
        COALESCE(
            x.fx_exposure,
            0
        ) AS combined_exposure

    FROM financial_risk f

    LEFT JOIN fx_risk x
        ON f.trade_id = x.trade_id
        AND f.currency_id = x.currency_id
),

ranked_risk AS (

    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY combined_exposure DESC
        ) AS risk_rank

    FROM combined_risk
)

SELECT
    'TRADES WITH FINANCIAL EXPOSURE' AS validation_metric,
    COUNT(*) AS value
FROM combined_risk

UNION ALL

SELECT
    'TOTAL FINANCIAL EXPOSURE',
    ROUND(
        SUM(financial_exposure),
        2
    )
FROM combined_risk

UNION ALL

SELECT
    'TOTAL FX EXPOSURE',
    ROUND(
        SUM(fx_exposure),
        2
    )
FROM combined_risk

UNION ALL

SELECT
    'TOTAL COMBINED EXPOSURE',
    ROUND(
        SUM(combined_exposure),
        2
    )
FROM combined_risk

UNION ALL

SELECT
    'TOP 5 RISK',
    ROUND(
        SUM(combined_exposure),
        2
    )
FROM ranked_risk
WHERE risk_rank <= 5

UNION ALL

SELECT
    'TOP 10 RISK',
    ROUND(
        SUM(combined_exposure),
        2
    )
FROM ranked_risk
WHERE risk_rank <= 10

UNION ALL

SELECT
    'TOP 20 RISK',
    ROUND(
        SUM(combined_exposure),
        2
    )
FROM ranked_risk
WHERE risk_rank <= 20

UNION ALL

SELECT
    'CRITICAL EXPOSURE',
    ROUND(
        SUM(
            CASE
                WHEN combined_exposure >= 110000
                THEN combined_exposure
                ELSE 0
            END
        ),
        2
    )
FROM combined_risk

UNION ALL

SELECT
    'HIGH EXPOSURE',
    ROUND(
        SUM(
            CASE
                WHEN combined_exposure >= 80000
                AND combined_exposure < 110000
                THEN combined_exposure
                ELSE 0
            END
        ),
        2
    )
FROM combined_risk;