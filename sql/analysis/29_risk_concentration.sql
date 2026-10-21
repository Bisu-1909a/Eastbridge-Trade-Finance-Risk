-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 29 — Risk Concentration Analysis
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
        i.invoice_amount
        - COALESCE(p.payment_amount, 0) > 0
),

fx_risk AS (

    SELECT
        fx.trade_id,

        fx.exposure_amount
            - COALESCE(h.hedged_amount, 0)
            AS unhedged_fx_exposure

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id
),

risk AS (

    SELECT

        f.trade_id,

        f.outstanding_amount
            + x.unhedged_fx_exposure
            AS combined_exposure,

        CASE

            WHEN
                f.outstanding_amount >= 90000
                AND x.unhedged_fx_exposure >= 30000
            THEN 'CRITICAL'

            WHEN
                x.unhedged_fx_exposure >= 20000
                OR f.outstanding_amount >= 80000
            THEN 'HIGH'

            WHEN
                x.unhedged_fx_exposure >= 10000
                OR f.outstanding_amount >= 50000
            THEN 'MEDIUM'

            ELSE 'LOW'

        END AS management_priority

    FROM financial_risk f

    JOIN fx_risk x
        ON f.trade_id = x.trade_id
),

totals AS (

    SELECT
        SUM(combined_exposure) AS total_combined_exposure
    FROM risk
)

SELECT

    r.management_priority,

    COUNT(*) AS trade_count,

    ROUND(
        SUM(r.combined_exposure),
        2
    ) AS combined_exposure,

    ROUND(
        SUM(r.combined_exposure) * 100.0
        / t.total_combined_exposure,
        2
    ) AS exposure_share_percentage

FROM risk r

CROSS JOIN totals t

GROUP BY
    r.management_priority

ORDER BY

    CASE r.management_priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END;