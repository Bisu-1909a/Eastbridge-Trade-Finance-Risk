-- ============================================================
-- 19 - FX Management Action Queue
-- ============================================================

SELECT
    fx.trade_id,
    fx.currency_id,

    ROUND(fx.exposure_amount, 2)
        AS exposure_amount,

    ROUND(h.hedged_amount, 2)
        AS hedged_amount,

    ROUND(
        fx.exposure_amount - h.hedged_amount,
        2
    ) AS unhedged_exposure,

    ROUND(
        (h.hedged_amount * 100.0)
        / fx.exposure_amount,
        2
    ) AS hedge_coverage_percentage,

    h.hedge_type,
    h.hedge_status,

    CASE
        WHEN fx.exposure_amount - h.hedged_amount >= 30000
            THEN 'CRITICAL'

        WHEN fx.exposure_amount - h.hedged_amount >= 20000
            THEN 'HIGH'

        ELSE 'MEDIUM'
    END AS risk_priority

FROM fx_exposure fx

JOIN hedge h
    ON fx.fx_exposure_id = h.fx_exposure_id

WHERE
    fx.exposure_amount - h.hedged_amount >= 20000

ORDER BY
    unhedged_exposure DESC;