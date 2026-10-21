WITH trade_risk AS (

    SELECT
        f.trade_id,

        f.outstanding_amount AS financial_exposure,

        COALESCE(
            x.unhedged_exposure,
            0
        ) AS fx_unhedged_exposure,

        f.outstanding_amount
        + COALESCE(x.unhedged_exposure, 0)
        AS combined_exposure

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
),

ranked AS (

    SELECT
        trade_id,
        combined_exposure,

        ROW_NUMBER() OVER (
            ORDER BY combined_exposure DESC
        ) AS risk_rank

    FROM trade_risk
),

total AS (

    SELECT
        SUM(combined_exposure) AS total_exposure
    FROM ranked
)

SELECT

    total.total_exposure,

    SUM(
        CASE
            WHEN risk_rank <= 5
            THEN combined_exposure
            ELSE 0
        END
    ) AS top_5_exposure,

    ROUND(
        SUM(
            CASE
                WHEN risk_rank <= 5
                THEN combined_exposure
                ELSE 0
            END
        ) * 100.0
        / total.total_exposure,
        2
    ) AS top_5_percentage,

    SUM(
        CASE
            WHEN risk_rank <= 10
            THEN combined_exposure
            ELSE 0
        END
    ) AS top_10_exposure,

    ROUND(
        SUM(
            CASE
                WHEN risk_rank <= 10
                THEN combined_exposure
                ELSE 0
            END
        ) * 100.0
        / total.total_exposure,
        2
    ) AS top_10_percentage,

    SUM(
        CASE
            WHEN risk_rank <= 15
            THEN combined_exposure
            ELSE 0
        END
    ) AS top_15_exposure,

    ROUND(
        SUM(
            CASE
                WHEN risk_rank <= 15
                THEN combined_exposure
                ELSE 0
            END
        ) * 100.0
        / total.total_exposure,
        2
    ) AS top_15_percentage

FROM ranked

CROSS JOIN total

GROUP BY total.total_exposure;