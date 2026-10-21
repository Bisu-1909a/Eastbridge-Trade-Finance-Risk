SELECT
    hedge_status,
    COUNT(*) AS trade_count,

    ROUND(SUM(financial_exposure), 2) AS financial_exposure,

    ROUND(SUM(fx_exposure), 2) AS fx_exposure,

    ROUND(SUM(combined_exposure), 2) AS combined_exposure,

    ROUND(
        SUM(combined_exposure) * 100.0 /
        SUM(SUM(combined_exposure)) OVER (),
        2
    ) AS exposure_percentage

FROM (
    SELECT
        t.trade_id,

        COALESCE(
            i.invoice_amount - p.payment_amount,
            0
        ) AS financial_exposure,

        COALESCE(
            fx.exposure_amount - h.hedged_amount,
            0
        ) AS fx_exposure,

        COALESCE(
            i.invoice_amount - p.payment_amount,
            0
        )
        +
        COALESCE(
            fx.exposure_amount - h.hedged_amount,
            0
        ) AS combined_exposure,

        h.hedge_status

    FROM trade t

    JOIN invoice i
        ON t.trade_id = i.trade_id

    JOIN payment p
        ON i.invoice_id = p.invoice_id

    JOIN fx_exposure fx
        ON t.trade_id = fx.trade_id

    JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    WHERE
        (
            i.invoice_amount - p.payment_amount
        ) > 0
        OR
        (
            fx.exposure_amount - h.hedged_amount
        ) > 0
)

GROUP BY hedge_status

ORDER BY combined_exposure DESC;