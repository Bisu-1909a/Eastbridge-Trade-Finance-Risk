-- ============================================================
-- 12 - FX Risk Summary
-- ============================================================

SELECT
    COUNT(*) AS total_fx_exposures,

    ROUND(SUM(fx.exposure_amount), 2)
        AS total_fx_exposure,

    ROUND(SUM(h.hedged_amount), 2)
        AS total_hedged_amount,

    ROUND(
        SUM(fx.exposure_amount - h.hedged_amount),
        2
    ) AS total_unhedged_exposure,

    ROUND(
        SUM(h.hedged_amount) * 100.0
        / NULLIF(SUM(fx.exposure_amount), 0),
        2
    ) AS overall_hedge_coverage_percentage,

    ROUND(
        AVG(
            fx.exposure_amount - h.hedged_amount
        ),
        2
    ) AS average_unhedged_exposure

FROM fx_exposure fx

JOIN hedge h
    ON fx.fx_exposure_id = h.fx_exposure_id;