WITH trade_exposure AS (
    SELECT
        i.trade_id,

        MAX(
            i.invoice_amount
            - COALESCE(p.payment_amount, 0)
        ) AS financial_exposure

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    WHERE
        i.invoice_amount
        - COALESCE(p.payment_amount, 0) > 0

    GROUP BY
        i.trade_id
),

fx_data AS (
    SELECT
        fx.trade_id,

        MAX(
            fx.exposure_amount
            - COALESCE(h.hedged_amount, 0)
        ) AS unhedged_fx_exposure

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    GROUP BY
        fx.trade_id
),

combined AS (
    SELECT
        t.trade_id,

        t.financial_exposure,

        COALESCE(f.unhedged_fx_exposure, 0)
            AS unhedged_fx_exposure,

        t.financial_exposure
        + COALESCE(f.unhedged_fx_exposure, 0)
            AS combined_exposure

    FROM trade_exposure t

    LEFT JOIN fx_data f
        ON t.trade_id = f.trade_id
),

prioritized AS (
    SELECT
        trade_id,
        financial_exposure,
        unhedged_fx_exposure,
        combined_exposure,

        CASE
            WHEN combined_exposure >= 120000
                THEN 'CRITICAL'

            WHEN combined_exposure >= 90000
                THEN 'HIGH'

            WHEN combined_exposure >= 60000
                THEN 'MEDIUM'

            ELSE 'LOW'
        END AS risk_priority

    FROM combined
)

SELECT
    trade_id,

    ROUND(financial_exposure, 2)
        AS financial_exposure,

    ROUND(unhedged_fx_exposure, 2)
        AS unhedged_fx_exposure,

    ROUND(combined_exposure, 2)
        AS combined_exposure,

    risk_priority,

    CASE risk_priority

        WHEN 'CRITICAL'
            THEN 'Immediate management intervention'

        WHEN 'HIGH'
            THEN 'Management review required'

        WHEN 'MEDIUM'
            THEN 'Monitor and review'

        ELSE
            'Routine monitoring'

    END AS recommended_action

FROM prioritized

WHERE risk_priority IN ('CRITICAL', 'HIGH')

ORDER BY
    CASE risk_priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
    END,

    combined_exposure DESC;

