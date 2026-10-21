-- ============================================================
-- 11 - FX Risk Exposure and Hedge Coverage
-- ============================================================

SELECT
    fx.fx_exposure_id,

    fx.trade_id,

    fx.currency_id,

    ROUND(fx.exposure_amount, 2)
        AS fx_exposure_amount,

    ROUND(h.hedged_amount, 2)
        AS hedged_amount,

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

    h.hedge_status

FROM fx_exposure fx

JOIN hedge h
    ON fx.fx_exposure_id = h.fx_exposure_id

ORDER BY
    unhedged_exposure DESC;