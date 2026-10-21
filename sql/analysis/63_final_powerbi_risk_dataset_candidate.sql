-- Eastbridge Trade Finance Risk
-- Candidate Power BI dataset: currency-specific risk ranking
-- Synthetic portfolio: recorded hedge amounts are not verified protection.
-- Monetary amounts remain in their original trade currencies.
-- Risk priorities are relative within each currency, not absolute loss thresholds.

WITH invoice_balances AS (
    SELECT
        i.invoice_id,
        i.trade_id,
        i.currency_id,
        MAX(COALESCE(i.invoice_amount, 0))
            - COALESCE(SUM(COALESCE(p.payment_amount, 0)), 0)
            AS outstanding_balance
    FROM invoice i
    LEFT JOIN payment p
        ON p.invoice_id = i.invoice_id
    GROUP BY
        i.invoice_id,
        i.trade_id,
        i.currency_id
),
financial_risk AS (
    SELECT
        trade_id,
        currency_id,
        SUM(MAX(outstanding_balance, 0)) AS financial_exposure
    FROM invoice_balances
    GROUP BY trade_id, currency_id
),
hedge_totals AS (
    SELECT
        fx_exposure_id,
        SUM(COALESCE(hedged_amount, 0)) AS recorded_hedge_amount,
        GROUP_CONCAT(DISTINCT COALESCE(hedge_status, 'UNKNOWN'))
            AS hedge_status,
        GROUP_CONCAT(DISTINCT COALESCE(hedge_type, 'UNKNOWN'))
            AS hedge_type
    FROM hedge
    GROUP BY fx_exposure_id
),
fx_risk AS (
    SELECT
        fx.trade_id,
        fx.currency_id,
        SUM(COALESCE(fx.exposure_amount, 0)) AS gross_fx_exposure,
        SUM(COALESCE(h.recorded_hedge_amount, 0))
            AS recorded_hedge_amount,
        SUM(
            MAX(
                COALESCE(fx.exposure_amount, 0)
                    - COALESCE(h.recorded_hedge_amount, 0),
                0
            )
        ) AS estimated_residual_fx_exposure,
        GROUP_CONCAT(DISTINCT COALESCE(h.hedge_status, 'UNHEDGED'))
            AS hedge_status,
        GROUP_CONCAT(DISTINCT COALESCE(h.hedge_type, 'UNHEDGED'))
            AS hedge_type
    FROM fx_exposure fx
    LEFT JOIN hedge_totals h
        ON h.fx_exposure_id = fx.fx_exposure_id
    GROUP BY fx.trade_id, fx.currency_id
),
risk_base AS (
    SELECT
        t.trade_id,
        t.trade_status,
        t.currency_id,
        COALESCE(fr.financial_exposure, 0) AS financial_exposure,
        COALESCE(xr.gross_fx_exposure, 0) AS gross_fx_exposure,
        COALESCE(xr.recorded_hedge_amount, 0) AS recorded_hedge_amount,
        CASE
            WHEN COALESCE(xr.gross_fx_exposure, 0) > 0
            THEN ROUND(
                100.0 * COALESCE(xr.recorded_hedge_amount, 0)
                    / xr.gross_fx_exposure,
                2
            )
            ELSE 0
        END AS recorded_hedge_coverage_percentage,
        COALESCE(xr.estimated_residual_fx_exposure, 0)
            AS fx_exposure,
        COALESCE(fr.financial_exposure, 0)
            + COALESCE(xr.estimated_residual_fx_exposure, 0)
            AS combined_exposure,
        COALESCE(xr.hedge_status, 'UNHEDGED') AS hedge_status,
        COALESCE(xr.hedge_type, 'UNHEDGED') AS hedge_type
    FROM trade t
    LEFT JOIN financial_risk fr
        ON fr.trade_id = t.trade_id
       AND fr.currency_id = t.currency_id
    LEFT JOIN fx_risk xr
        ON xr.trade_id = t.trade_id
       AND xr.currency_id = t.currency_id
),
ranked_risk AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY currency_id
            ORDER BY combined_exposure DESC, trade_id
        ) AS risk_rank,
        COUNT(*) OVER (
            PARTITION BY currency_id
        ) AS currency_trade_count
    FROM risk_base
),
prioritized_risk AS (
    SELECT
        *,
        CASE
            WHEN risk_rank <= MAX(1, CAST(CEIL(currency_trade_count * 0.10) AS INTEGER))
                THEN 'CRITICAL'
            WHEN risk_rank <= MAX(1, CAST(CEIL(currency_trade_count * 0.30) AS INTEGER))
                THEN 'HIGH'
            WHEN risk_rank <= MAX(1, CAST(CEIL(currency_trade_count * 0.60) AS INTEGER))
                THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_priority
    FROM ranked_risk
)
SELECT
    trade_id,
    trade_status,
    currency_id,
    ROUND(financial_exposure, 2) AS financial_exposure,
    ROUND(fx_exposure, 2) AS fx_exposure,
    ROUND(combined_exposure, 2) AS combined_exposure,
    hedge_status,
    hedge_type,
    risk_priority,
    risk_rank,
    CASE risk_priority
        WHEN 'CRITICAL' THEN 'Review exposure and recorded hedge coverage urgently'
        WHEN 'HIGH' THEN 'Review payment balance and recorded hedge coverage'
        WHEN 'MEDIUM' THEN 'Monitor outstanding balance and FX coverage'
        ELSE 'Continue routine monitoring'
    END AS management_action,
    ROUND(gross_fx_exposure, 2) AS gross_fx_exposure,
    ROUND(recorded_hedge_amount, 2) AS recorded_hedge_amount,
    recorded_hedge_coverage_percentage
FROM prioritized_risk
ORDER BY currency_id, risk_rank;
