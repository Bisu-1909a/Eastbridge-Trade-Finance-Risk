WITH combined_risk AS (

    SELECT
        t.trade_id,

        COALESCE(
            i.outstanding_amount,
            0
        ) AS financial_exposure,

        COALESCE(
            fx.unhedged_amount,
            0
        ) AS fx_exposure,

        COALESCE(
            i.outstanding_amount,
            0
        ) +
        COALESCE(
            fx.unhedged_amount,
            0
        ) AS combined_exposure,

        h.hedge_type

    FROM trade t

    LEFT JOIN (
        SELECT
            i.trade_id,
            MAX(
                i.invoice_amount - COALESCE(p.total_paid, 0)
            ) AS outstanding_amount

        FROM invoice i

        LEFT JOIN (
            SELECT
                invoice_id,
                SUM(payment_amount) AS total_paid
            FROM payment
            GROUP BY invoice_id
        ) p
            ON i.invoice_id = p.invoice_id

        WHERE
            i.invoice_amount - COALESCE(p.total_paid, 0) > 0

        GROUP BY i.trade_id
    ) i
        ON t.trade_id = i.trade_id

    LEFT JOIN (
        SELECT
            fx.fx_exposure_id,
            fx.trade_id,
            fx.exposure_amount
                - COALESCE(h.hedged_amount, 0)
                AS unhedged_amount

        FROM fx_exposure fx

        LEFT JOIN (
            SELECT
                fx_exposure_id,
                SUM(hedged_amount) AS hedged_amount
            FROM hedge
            GROUP BY fx_exposure_id
        ) h
            ON fx.fx_exposure_id = h.fx_exposure_id
    ) fx
        ON t.trade_id = fx.trade_id

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id
)

SELECT
    hedge_type,
    COUNT(DISTINCT trade_id) AS trade_count,

    ROUND(
        SUM(financial_exposure),
        2
    ) AS financial_exposure,

    ROUND(
        SUM(fx_exposure),
        2
    ) AS fx_unhedged_exposure,

    ROUND(
        SUM(combined_exposure),
        2
    ) AS combined_exposure,

    ROUND(
        100.0 *
        SUM(combined_exposure) /
        SUM(SUM(combined_exposure))
        OVER (),
        2
    ) AS exposure_percentage

FROM combined_risk

WHERE hedge_type IS NOT NULL

GROUP BY hedge_type

ORDER BY combined_exposure DESC;