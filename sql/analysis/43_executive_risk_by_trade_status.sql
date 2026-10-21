/*
===========================================================
Mission 43
Executive Risk by Trade Status

Purpose:
Show where combined financial + FX exposure is concentrated
across the trade lifecycle.

Output:
- Trade status
- Number of trades
- Financial exposure
- FX exposure
- Combined exposure
- Percentage of total combined exposure

Used for:
- Executive dashboard
- Risk concentration analysis
- Trade lifecycle monitoring
===========================================================
*/

WITH combined_risk AS (

    SELECT
        t.trade_id,
        t.trade_status,

        COALESCE(
            t.expected_revenue,
            0
        ) AS financial_exposure,

        COALESCE(
            fx.exposure_amount - COALESCE(h.hedged_amount, 0),
            0
        ) AS fx_unhedged_exposure

    FROM trade t

    LEFT JOIN fx_exposure fx
        ON t.trade_id = fx.trade_id

    LEFT JOIN (
        SELECT
            fx_exposure_id,
            SUM(hedged_amount) AS hedged_amount
        FROM hedge
        GROUP BY fx_exposure_id
    ) h
        ON fx.fx_exposure_id = h.fx_exposure_id
),

status_summary AS (

    SELECT
        trade_status,
        COUNT(DISTINCT trade_id) AS trade_count,
        ROUND(SUM(financial_exposure), 2) AS financial_exposure,
        ROUND(SUM(fx_unhedged_exposure), 2) AS fx_unhedged_exposure,
        ROUND(
            SUM(financial_exposure + fx_unhedged_exposure),
            2
        ) AS combined_exposure

    FROM combined_risk

    GROUP BY trade_status
)

SELECT
    trade_status,
    trade_count,
    financial_exposure,
    fx_unhedged_exposure,
    combined_exposure,

    ROUND(
        combined_exposure * 100.0 /
        SUM(combined_exposure) OVER (),
        2
    ) AS exposure_percentage

FROM status_summary

ORDER BY combined_exposure DESC;