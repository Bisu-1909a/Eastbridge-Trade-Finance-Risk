-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 28 — Management Risk Summary
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

        f.outstanding_amount,

        x.unhedged_fx_exposure,

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
)

SELECT

    management_priority,

    COUNT(*) AS trade_count,

    ROUND(
        SUM(outstanding_amount),
        2
    ) AS financial_exposure,

    ROUND(
        SUM(unhedged_fx_exposure),
        2
    ) AS unhedged_fx_exposure,

    ROUND(
        SUM(combined_exposure),
        2
    ) AS combined_exposure,

    ROUND(
        AVG(combined_exposure),
        2
    ) AS average_combined_exposure

FROM risk

GROUP BY
    management_priority

ORDER BY

    CASE management_priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END;