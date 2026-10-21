-- ============================================================
-- 20 - FX Management Queue by Currency
-- ============================================================

WITH management_queue AS (

    SELECT
        fx.trade_id,
        fx.currency_id,

        fx.exposure_amount - h.hedged_amount
            AS unhedged_exposure

    FROM fx_exposure fx

    JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    WHERE
        fx.exposure_amount - h.hedged_amount >= 20000
)

SELECT
    currency_id,

    COUNT(*) AS priority_trade_count,

    ROUND(
        SUM(unhedged_exposure),
        2
    ) AS total_unhedged_exposure,

    ROUND(
        AVG(unhedged_exposure),
        2
    ) AS average_unhedged_exposure

FROM management_queue

GROUP BY
    currency_id

ORDER BY
    total_unhedged_exposure DESC;