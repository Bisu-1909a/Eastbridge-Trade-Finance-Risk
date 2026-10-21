-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 63 — Final Power BI Risk Dataset
--
-- Purpose:
-- Create the final trade-level dataset for Power BI.
--
-- Grain:
-- 1 row per trade
--
-- This dataset combines:
--   1. Financial exposure
--   2. Unhedged FX exposure
--   3. Combined exposure
--   4. Trade status
--   5. Currency
--   6. Hedge information
--   7. Risk priority
--   8. Risk ranking
--   9. Management action
-- ============================================================

WITH financial_risk AS (

    SELECT
        i.trade_id,
        i.currency_id,

        MAX(i.invoice_amount)
        - COALESCE(
            SUM(p.payment_amount),
            0
        ) AS financial_exposure

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    GROUP BY
        i.trade_id,
        i.currency_id

    HAVING
        financial_exposure > 0
),

fx_risk AS (

    SELECT
        fx.trade_id,
        fx.currency_id,

        SUM(
            fx.exposure_amount
            - COALESCE(h.hedged_amount, 0)
        ) AS fx_exposure,

        MAX(
            COALESCE(
                h.hedge_status,
                'UNHEDGED'
            )
        ) AS hedge_status,

        MAX(
            COALESCE(
                h.hedge_type,
                'UNHEDGED'
            )
        ) AS hedge_type

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    GROUP BY
        fx.trade_id,
        fx.currency_id
),

risk_base AS (

    SELECT

        t.trade_id,
        t.trade_status,

        COALESCE(
            fr.currency_id,
            fx.currency_id
        ) AS currency_id,

        COALESCE(
            fr.financial_exposure,
            0
        ) AS financial_exposure,

        COALESCE(
            fx.fx_exposure,
            0
        ) AS fx_exposure,

        COALESCE(
            fr.financial_exposure,
            0
        )
        +
        COALESCE(
            fx.fx_exposure,
            0
        ) AS combined_exposure,

        COALESCE(
            fx.hedge_status,
            'UNHEDGED'
        ) AS hedge_status,

        COALESCE(
            fx.hedge_type,
            'UNHEDGED'
        ) AS hedge_type

    FROM trade t

    LEFT JOIN financial_risk fr
        ON t.trade_id = fr.trade_id

    LEFT JOIN fx_risk fx
        ON t.trade_id = fx.trade_id
        AND (
            fr.currency_id = fx.currency_id
            OR fr.currency_id IS NULL
        )
),

ranked_risk AS (

    SELECT

        *,

        ROW_NUMBER() OVER (
            ORDER BY
                combined_exposure DESC,
                trade_id
        ) AS risk_rank

    FROM risk_base
),

final_dataset AS (

    SELECT

        trade_id,
        trade_status,
        currency_id,

        ROUND(
            financial_exposure,
            2
        ) AS financial_exposure,

        ROUND(
            fx_exposure,
            2
        ) AS fx_exposure,

        ROUND(
            combined_exposure,
            2
        ) AS combined_exposure,

        hedge_status,
        hedge_type,

        CASE

            WHEN risk_rank <= 3
                THEN 'CRITICAL'

            WHEN risk_rank <= 16
                THEN 'HIGH'

            WHEN risk_rank <= 30
                THEN 'MEDIUM'

            ELSE 'LOW'

        END AS risk_priority,

        risk_rank,

        CASE

            WHEN risk_rank <= 3
                THEN 'Immediate management intervention'

            WHEN risk_rank <= 16
                THEN 'Management review required'

            WHEN risk_rank <= 30
                THEN 'Monitor and review'

            ELSE 'Routine monitoring'

        END AS management_action

    FROM ranked_risk
)

SELECT

    trade_id,
    trade_status,
    currency_id,

    financial_exposure,
    fx_exposure,
    combined_exposure,

    hedge_status,
    hedge_type,

    risk_priority,
    risk_rank,
    management_action

FROM final_dataset

ORDER BY
    risk_rank;