-- ============================================================
-- 21 - FX Currency Risk Concentration
-- ============================================================

WITH management_queue AS (

    SELECT
        fx.currency_id,

        fx.exposure_amount - h.hedged_amount
            AS unhedged_exposure

    FROM fx_exposure fx

    JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    WHERE
        fx.exposure_amount - h.hedged_amount >= 20000
),

currency_summary AS (

    SELECT
        currency_id,

        COUNT(*) AS priority_trade_count,

        SUM(unhedged_exposure)
            AS total_unhedged_exposure

    FROM management_queue

    GROUP BY
        currency_id
)

SELECT
    currency_id,

    priority_trade_count,

    ROUND(
        total_unhedged_exposure,
        2
    ) AS total_unhedged_exposure,

    ROUND(
        total_unhedged_exposure * 100.0
        / SUM(total_unhedged_exposure) OVER (),
        2
    ) AS exposure_concentration_percentage

FROM currency_summary

ORDER BY
    total_unhedged_exposure DESC;