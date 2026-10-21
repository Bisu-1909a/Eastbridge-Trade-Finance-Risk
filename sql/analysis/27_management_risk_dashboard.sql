/*
EastBridge Trade Finance Risk
Mission 27 — Management Risk Dashboard

Purpose:
Identify trades requiring management attention by combining:

1. Outstanding financial exposure
2. Unhedged FX exposure
3. Combined financial + FX exposure
4. Financial status
5. Shipment status
6. FX hedge priority
*/

WITH financial_risk AS (

    SELECT
        i.trade_id,
        i.invoice_amount,
        COALESCE(p.payment_amount, 0) AS payment_amount,

        i.invoice_amount
            - COALESCE(p.payment_amount, 0) AS outstanding_amount,

        i.invoice_status

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    WHERE
        i.invoice_amount
        - COALESCE(p.payment_amount, 0) > 0
),

fx_risk AS (

    SELECT
        fx.trade_id,

        fx.exposure_amount,

        COALESCE(h.hedged_amount, 0) AS hedged_amount,

        fx.exposure_amount
            - COALESCE(h.hedged_amount, 0) AS unhedged_amount,

        CASE
            WHEN
                fx.exposure_amount > 0
            THEN
                ROUND(
                    (
                        (
                            fx.exposure_amount
                            - COALESCE(h.hedged_amount, 0)
                        )
                        / fx.exposure_amount
                    ) * 100,
                    2
                )
            ELSE 0
        END AS hedge_gap_percentage,

        h.hedge_type,
        h.hedge_status

    FROM fx_exposure fx

    LEFT JOIN hedge h
        ON fx.fx_exposure_id = h.fx_exposure_id

),

shipment_risk AS (

    SELECT
        trade_id,
        shipment_status

    FROM shipment
)

SELECT

    f.trade_id,

    ROUND(f.outstanding_amount, 2)
        AS outstanding_financial_exposure,

    ROUND(x.unhedged_amount, 2)
        AS unhedged_fx_exposure,

    ROUND(
        f.outstanding_amount
        + x.unhedged_amount,
        2
    ) AS combined_risk_exposure,

    f.invoice_status,

    s.shipment_status,

    x.hedge_type,

    x.hedge_status,

    ROUND(x.hedge_gap_percentage, 2)
        AS hedge_gap_percentage,

    CASE

        WHEN
            x.unhedged_amount >= 30000
            AND f.outstanding_amount >= 90000
        THEN 'CRITICAL'

        WHEN
            x.unhedged_amount >= 20000
            OR f.outstanding_amount >= 80000
        THEN 'HIGH'

        WHEN
            x.unhedged_amount >= 10000
            OR f.outstanding_amount >= 50000
        THEN 'MEDIUM'

        ELSE 'LOW'

    END AS management_priority

FROM financial_risk f

JOIN fx_risk x
    ON f.trade_id = x.trade_id

JOIN shipment_risk s
    ON f.trade_id = s.trade_id

ORDER BY

    CASE management_priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END,

    combined_risk_exposure DESC;