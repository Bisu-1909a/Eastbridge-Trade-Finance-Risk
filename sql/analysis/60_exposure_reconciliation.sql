-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 60 — Exposure Reconciliation
--
-- Purpose:
-- Reconcile financial exposure, FX exposure and combined
-- exposure across open receivables and the full FX portfolio.
--
-- Key distinction:
--
-- 1. Financial exposure
--    Outstanding customer receivable.
--
-- 2. Open-receivable FX exposure
--    FX exposure attached to trades with outstanding
--    customer receivables.
--
-- 3. Completed-trade FX exposure
--    FX exposure belonging to completed trades that is
--    not included in the open-receivable view.
--
-- 4. Portfolio FX exposure
--    All unhedged FX exposure.
--
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
        ) AS unhedged_fx_exposure

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

    GROUP BY
        fx.trade_id,
        fx.currency_id
),

open_receivable_fx AS (

    SELECT
        x.trade_id,
        SUM(
            x.unhedged_fx_exposure
        ) AS fx_exposure

    FROM fx_risk x

    INNER JOIN financial_risk f
        ON x.trade_id = f.trade_id
        AND x.currency_id = f.currency_id

    GROUP BY
        x.trade_id
),

completed_fx AS (

    SELECT
        SUM(
            x.unhedged_fx_exposure
        ) AS fx_exposure

    FROM fx_risk x

    INNER JOIN trade t
        ON x.trade_id = t.trade_id

    WHERE
        t.trade_status = 'COMPLETED'
),

portfolio_fx AS (

    SELECT
        SUM(
            unhedged_fx_exposure
        ) AS fx_exposure

    FROM fx_risk
),

financial_total AS (

    SELECT
        SUM(financial_exposure)
            AS financial_exposure

    FROM financial_risk
),

open_combined AS (

    SELECT
        f.financial_exposure
        +
        COALESCE(
            o.fx_exposure,
            0
        ) AS combined_exposure

    FROM financial_risk f

    LEFT JOIN open_receivable_fx o
        ON f.trade_id = o.trade_id
)

SELECT
    'FINANCIAL EXPOSURE' AS metric,
    ROUND(
        financial_exposure,
        2
    ) AS value
FROM financial_total

UNION ALL

SELECT
    'OPEN RECEIVABLE FX EXPOSURE',
    ROUND(
        COALESCE(
            SUM(fx_exposure),
            0
        ),
        2
    )
FROM open_receivable_fx

UNION ALL

SELECT
    'COMPLETED TRADE FX EXPOSURE',
    ROUND(
        COALESCE(
            fx_exposure,
            0
        ),
        2
    )
FROM completed_fx

UNION ALL

SELECT
    'TOTAL PORTFOLIO FX EXPOSURE',
    ROUND(
        COALESCE(
            fx_exposure,
            0
        ),
        2
    )
FROM portfolio_fx

UNION ALL

SELECT
    'OPEN COMBINED EXPOSURE',
    ROUND(
        SUM(combined_exposure),
        2
    )
FROM open_combined

UNION ALL

SELECT
    'PORTFOLIO COMBINED EXPOSURE',
    ROUND(
        (
            SELECT financial_exposure
            FROM financial_total
        )
        +
        (
            SELECT fx_exposure
            FROM portfolio_fx
        ),
        2
    );