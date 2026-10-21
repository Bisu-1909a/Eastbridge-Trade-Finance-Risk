-- ============================================================
-- 09 - Risk Exposure Percentage
-- ============================================================

WITH risk_summary AS (

    SELECT
        CASE
            WHEN p.payment_status = 'OVERDUE'
                 AND s.shipment_status IN ('DELAYED', 'IN_TRANSIT')
                THEN 'CRITICAL_RISK'

            WHEN p.payment_status = 'OVERDUE'
                THEN 'FINANCIAL_RISK'

            WHEN s.shipment_status = 'DELAYED'
                THEN 'OPERATIONAL_RISK'

            WHEN s.shipment_status = 'IN_TRANSIT'
                THEN 'MONITOR'

            ELSE 'STANDARD'
        END AS risk_category,

        SUM(i.invoice_amount - p.payment_amount)
            AS outstanding_exposure

    FROM trade t

    JOIN invoice i
        ON t.trade_id = i.trade_id

    JOIN payment p
        ON i.invoice_id = p.invoice_id

    JOIN shipment s
        ON t.trade_id = s.trade_id

    WHERE i.invoice_amount - p.payment_amount > 0

    GROUP BY risk_category
)

SELECT
    risk_category,

    ROUND(outstanding_exposure, 2)
        AS outstanding_exposure,

    ROUND(
        outstanding_exposure * 100.0 /
        SUM(outstanding_exposure) OVER (),
        2
    ) AS exposure_percentage

FROM risk_summary

ORDER BY
    exposure_percentage DESC;