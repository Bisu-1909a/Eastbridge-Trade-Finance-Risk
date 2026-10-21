WITH financial_risk AS (

    SELECT
        i.trade_id,
        i.currency_id,

        MAX(i.invoice_amount)
        - COALESCE(SUM(p.payment_amount), 0)
        AS financial_exposure

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    GROUP BY
        i.trade_id,
        i.currency_id

    HAVING financial_exposure > 0
),

fx_risk AS (

    SELECT
        fx.trade_id,
        fx.currency_id,

        fx.exposure_amount
        - COALESCE(h.hedged_amount, 0)
        AS fx_unhedged_exposure

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id
),

combined AS (

    SELECT
        f.currency_id,

        f.financial_exposure,

        COALESCE(
            x.fx_unhedged_exposure,
            0
        ) AS fx_unhedged_exposure,

        f.financial_exposure
        + COALESCE(
            x.fx_unhedged_exposure,
            0
        ) AS combined_exposure

    FROM financial_risk f

    LEFT JOIN fx_risk x
        ON f.trade_id = x.trade_id
        AND f.currency_id = x.currency_id
),

currency_summary AS (

    SELECT
        currency_id,

        SUM(financial_exposure)
        AS financial_exposure,

        SUM(fx_unhedged_exposure)
        AS fx_unhedged_exposure,

        SUM(combined_exposure)
        AS combined_exposure

    FROM combined

    GROUP BY currency_id
),

portfolio_total AS (

    SELECT
        SUM(combined_exposure)
        AS total_combined_exposure

    FROM currency_summary
)

SELECT

    c.currency_id,

    c.financial_exposure,

    c.fx_unhedged_exposure,

    c.combined_exposure,

    ROUND(
        c.combined_exposure * 100.0
        / p.total_combined_exposure,
        2
    ) AS concentration_percentage

FROM currency_summary c

CROSS JOIN portfolio_total p

ORDER BY
    c.combined_exposure DESC;