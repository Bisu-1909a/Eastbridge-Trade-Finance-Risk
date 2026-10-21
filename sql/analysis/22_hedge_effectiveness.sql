-- ============================================================
-- 22 - FX Hedge Effectiveness by Hedge Type
-- ============================================================

SELECT
    h.hedge_type,

    COUNT(*) AS hedge_count,

    ROUND(
        SUM(fx.exposure_amount),
        2
    ) AS total_fx_exposure,

    ROUND(
        SUM(h.hedged_amount),
        2
    ) AS total_hedged_amount,

    ROUND(
        SUM(fx.exposure_amount - h.hedged_amount),
        2
    ) AS total_unhedged_exposure,

    ROUND(
        SUM(h.hedged_amount) * 100.0
        / NULLIF(SUM(fx.exposure_amount), 0),
        2
    ) AS hedge_effectiveness_percentage

FROM fx_exposure fx

JOIN hedge h
    ON fx.fx_exposure_id = h.fx_exposure_id

GROUP BY
    h.hedge_type

ORDER BY
    hedge_effectiveness_percentage DESC;