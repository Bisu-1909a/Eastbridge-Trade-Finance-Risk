SELECT
    trade_id,
    financial_exposure,
    fx_unhedged_exposure,
    combined_exposure,
    risk_level,
    ROUND(
        combined_exposure * 100.0 /
        SUM(combined_exposure) OVER (),
        2
    ) AS exposure_percentage
FROM (
    SELECT
        trade_id,
        financial_exposure,
        fx_unhedged_exposure,
        combined_exposure,
        risk_level
    FROM (
        SELECT
            f.trade_id,

            f.outstanding_amount AS financial_exposure,

            COALESCE(
                x.unhedged_exposure,
                0
            ) AS fx_unhedged_exposure,

            f.outstanding_amount
            + COALESCE(x.unhedged_exposure, 0)
            AS combined_exposure,

            CASE
                WHEN f.outstanding_amount
                     + COALESCE(x.unhedged_exposure, 0) >= 120000
                    THEN 'CRITICAL'

                WHEN f.outstanding_amount
                     + COALESCE(x.unhedged_exposure, 0) >= 90000
                    THEN 'HIGH'

                WHEN f.outstanding_amount
                     + COALESCE(x.unhedged_exposure, 0) >= 60000
                    THEN 'MEDIUM'

                ELSE 'LOW'
            END AS risk_level

        FROM (
            SELECT
                i.trade_id,
                MAX(i.invoice_amount)
                - COALESCE(SUM(p.payment_amount), 0)
                AS outstanding_amount
            FROM invoice i
            LEFT JOIN payment p
                ON i.invoice_id = p.invoice_id
            GROUP BY i.trade_id
            HAVING outstanding_amount > 0
        ) f

        LEFT JOIN (
            SELECT
                fx.trade_id,
                fx.exposure_amount
                - COALESCE(h.hedged_amount, 0)
                AS unhedged_exposure
            FROM fx_exposure fx
            LEFT JOIN hedge h
                ON fx.fx_exposure_id = h.fx_exposure_id
        ) x
            ON f.trade_id = x.trade_id
    )
)
ORDER BY combined_exposure DESC
LIMIT 15;