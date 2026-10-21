-- ============================================================
-- 26 - Executive Combined Risk KPIs
-- ============================================================

WITH financial_risk AS (

    SELECT
        i.trade_id,

        i.invoice_amount
        - COALESCE(p.payment_amount, 0)
            AS outstanding_amount

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    WHERE
        i.invoice_amount - COALESCE(p.payment_amount, 0) > 0
),

fx_risk AS (

    SELECT
        fx.trade_id,

        fx.exposure_amount - h.hedged_amount
            AS unhedged_fx_exposure

    FROM fx_exposure fx

    JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id
),

combined AS (

    SELECT
        f.trade_id,

        f.outstanding_amount,

        x.unhedged_fx_exposure,

        f.outstanding_amount
        + x.unhedged_fx_exposure
            AS combined_risk,

        CASE
            WHEN f.outstanding_amount >= 50000
                 AND x.unhedged_fx_exposure >= 30000
                THEN 'CRITICAL'

            WHEN f.outstanding_amount >= 50000
                 OR x.unhedged_fx_exposure >= 30000
                THEN 'HIGH'

            WHEN f.outstanding_amount >= 20000
                 AND x.unhedged_fx_exposure >= 20000
                THEN 'MEDIUM'

            ELSE 'LOW'
        END AS risk_level

    FROM financial_risk f

    JOIN fx_risk x
        ON f.trade_id = x.trade_id
)

SELECT

    COUNT(*) AS trades_with_risk,

    ROUND(
        SUM(outstanding_amount),
        2
    ) AS total_financial_exposure,

    ROUND(
        SUM(unhedged_fx_exposure),
        2
    ) AS total_unhedged_fx_exposure,

    ROUND(
        SUM(combined_risk),
        2
    ) AS total_combined_risk,

    SUM(
        CASE
            WHEN risk_level = 'CRITICAL'
            THEN 1
            ELSE 0
        END
    ) AS critical_trade_count,

    ROUND(
        SUM(
            CASE
                WHEN risk_level = 'CRITICAL'
                THEN combined_risk
                ELSE 0
            END
        ),
        2
    ) AS critical_combined_exposure,

    SUM(
        CASE
            WHEN risk_level = 'HIGH'
            THEN 1
            ELSE 0
        END
    ) AS high_trade_count,

    ROUND(
        SUM(
            CASE
                WHEN risk_level = 'HIGH'
                THEN combined_risk
                ELSE 0
            END
        ),
        2
    ) AS high_combined_exposure

FROM combined;