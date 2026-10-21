-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 49 — Executive Risk Concentration
--
-- Purpose:
-- Measure how much total combined exposure is concentrated
-- in the highest-risk trades.
--
-- Grain:
-- 1 row per concentration group
--
-- Definitions:
-- Financial Exposure = Outstanding customer receivable
-- FX Exposure        = Unhedged FX exposure
-- Combined Exposure  = Financial + Unhedged FX
-- ============================================================

WITH payment_summary AS (

    SELECT
        i.trade_id,

        SUM(i.invoice_amount) AS invoice_amount,

        SUM(
            COALESCE(p.payment_amount, 0)
        ) AS payment_amount

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    GROUP BY
        i.trade_id
),

financial_risk AS (

    SELECT
        trade_id,

        ROUND(
            invoice_amount - payment_amount,
            2
        ) AS financial_exposure

    FROM payment_summary

    WHERE
        invoice_amount - payment_amount > 0
),

hedge_summary AS (

    SELECT
        fx.trade_id,

        SUM(
            fx.exposure_amount
        ) AS fx_exposure,

        SUM(
            COALESCE(h.hedged_amount, 0)
        ) AS hedged_amount

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    GROUP BY
        fx.trade_id
),

fx_risk AS (

    SELECT
        trade_id,

        ROUND(
            MAX(
                fx_exposure - hedged_amount,
                0
            ),
            2
        ) AS unhedged_fx_exposure

    FROM hedge_summary

    GROUP BY
        trade_id
),

combined_risk AS (

    SELECT

        t.trade_id,

        COALESCE(
            f.financial_exposure,
            0
        ) AS financial_exposure,

        COALESCE(
            x.unhedged_fx_exposure,
            0
        ) AS unhedged_fx_exposure,

        ROUND(
            COALESCE(
                f.financial_exposure,
                0
            )
            +
            COALESCE(
                x.unhedged_fx_exposure,
                0
            ),
            2
        ) AS combined_exposure

    FROM trade t

    LEFT JOIN financial_risk f
        ON t.trade_id = f.trade_id

    LEFT JOIN fx_risk x
        ON t.trade_id = x.trade_id
),

ranked_risk AS (

    SELECT

        trade_id,

        combined_exposure,

        ROW_NUMBER() OVER (
            ORDER BY
                combined_exposure DESC,
                trade_id
        ) AS risk_rank

    FROM combined_risk
),

total_risk AS (

    SELECT
        SUM(combined_exposure)
            AS total_combined_exposure

    FROM combined_risk
)

SELECT

    'TOP 5' AS concentration_group,

    5 AS trade_count,

    ROUND(
        SUM(r.combined_exposure),
        2
    ) AS combined_exposure,

    ROUND(
        100.0
        * SUM(r.combined_exposure)
        / NULLIF(
            t.total_combined_exposure,
            0
        ),
        2
    ) AS risk_share_percentage

FROM ranked_risk r

CROSS JOIN total_risk t

WHERE
    r.risk_rank <= 5

UNION ALL

SELECT

    'TOP 10',

    10,

    ROUND(
        SUM(r.combined_exposure),
        2
    ),

    ROUND(
        100.0
        * SUM(r.combined_exposure)
        / NULLIF(
            t.total_combined_exposure,
            0
        ),
        2
    )

FROM ranked_risk r

CROSS JOIN total_risk t

WHERE
    r.risk_rank <= 10

UNION ALL

SELECT

    'TOP 20',

    20,

    ROUND(
        SUM(r.combined_exposure),
        2
    ),

    ROUND(
        100.0
        * SUM(r.combined_exposure)
        / NULLIF(
            t.total_combined_exposure,
            0
        ),
        2
    )

FROM ranked_risk r

CROSS JOIN total_risk t

WHERE
    r.risk_rank <= 20;