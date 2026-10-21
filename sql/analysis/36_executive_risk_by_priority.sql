WITH risk_data AS (
    SELECT
        trade_id,
        combined_exposure,
        CASE
            WHEN combined_exposure >= 120000 THEN 'CRITICAL'
            WHEN combined_exposure >= 90000 THEN 'HIGH'
            WHEN combined_exposure >= 60000 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_priority
    FROM (
        SELECT
            f.trade_id,
            f.outstanding_amount
                + COALESCE(x.unhedged_exposure, 0) AS combined_exposure
        FROM (
            SELECT
                i.trade_id,
                MAX(
                    i.invoice_amount
                    - COALESCE(p.payment_amount, 0)
                ) AS outstanding_amount
            FROM invoice i
            LEFT JOIN payment p
                ON i.invoice_id = p.invoice_id
            WHERE
                i.invoice_amount
                - COALESCE(p.payment_amount, 0) > 0
            GROUP BY i.trade_id
        ) f
        LEFT JOIN (
            SELECT
                fx.trade_id,
                fx.exposure_amount
                - COALESCE(h.hedged_amount, 0) AS unhedged_exposure
            FROM fx_exposure fx
            LEFT JOIN hedge h
                ON fx.fx_exposure_id = h.fx_exposure_id
        ) x
            ON f.trade_id = x.trade_id
    )
)

SELECT
    risk_priority,

    COUNT(*) AS trade_count,

    ROUND(SUM(combined_exposure), 2)
        AS total_combined_exposure,

    ROUND(AVG(combined_exposure), 2)
        AS average_exposure,

    ROUND(
        100.0 * SUM(combined_exposure)
        / NULLIF(
            (SELECT SUM(combined_exposure) FROM risk_data),
            0
        ),
        2
    ) AS exposure_percentage

FROM risk_data

GROUP BY risk_priority

ORDER BY
    CASE risk_priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END;