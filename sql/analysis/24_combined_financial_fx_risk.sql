-- ============================================================
-- 24 - Combined Financial + FX Risk
-- ============================================================

WITH financial_risk AS (

    SELECT
        i.trade_id,

        ROUND(
            i.invoice_amount - COALESCE(p.payment_amount, 0),
            2
        ) AS outstanding_amount

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    WHERE
        i.invoice_amount - COALESCE(p.payment_amount, 0) > 0
),

fx_risk AS (

    SELECT
        fx.trade_id,

        ROUND(
            fx.exposure_amount - h.hedged_amount,
            2
        ) AS unhedged_fx_exposure

    FROM fx_exposure fx

    JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id
)

SELECT
    f.trade_id,

    f.outstanding_amount,

    x.unhedged_fx_exposure,

    ROUND(
        f.outstanding_amount
        + x.unhedged_fx_exposure,
        2
    ) AS combined_risk_exposure,

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
    END AS combined_risk_level

FROM financial_risk f

JOIN fx_risk x
    ON f.trade_id = x.trade_id

ORDER BY
    combined_risk_exposure DESC;