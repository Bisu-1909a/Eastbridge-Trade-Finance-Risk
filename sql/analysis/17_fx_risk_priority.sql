-- ============================================================
-- 17 - FX Risk Priority Classification
-- ============================================================

SELECT
    fx.trade_id,
    fx.currency_id,

    ROUND(
        fx.exposure_amount,
        2
    ) AS fx_exposure,

    ROUND(
        h.hedged_amount,
        2
    ) AS hedged_amount,

    ROUND(
        fx.exposure_amount - h.hedged_amount,
        2
    ) AS unhedged_exposure,

    ROUND(
        h.hedged_amount * 100.0
        / NULLIF(fx.exposure_amount, 0),
        2
    ) AS hedge_coverage_percentage,

    h.hedge_type,
    h.hedge_status,

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

ORDER BY
    CASE
        WHEN fx.exposure_amount - h.hedged_amount >= 30000
            THEN 1
        WHEN fx.exposure_amount - h.hedged_amount >= 20000
            THEN 2
        WHEN fx.exposure_amount - h.hedged_amount >= 10000
            THEN 3
        ELSE 4
    END,

    unhedged_exposure DESC;