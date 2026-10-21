-- ============================================================
-- 07 - Critical Combined Trade Risk
-- ============================================================

SELECT
    t.trade_id,

    ROUND(i.invoice_amount - p.payment_amount, 2)
        AS outstanding_amount,

    p.payment_status,

    s.shipment_status,

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
    END AS risk_category

FROM trade t

JOIN invoice i
    ON t.trade_id = i.trade_id

JOIN payment p
    ON i.invoice_id = p.invoice_id

JOIN shipment s
    ON t.trade_id = s.trade_id

WHERE i.invoice_amount - p.payment_amount > 0

ORDER BY
    CASE
        WHEN p.payment_status = 'OVERDUE'
             AND s.shipment_status IN ('DELAYED', 'IN_TRANSIT')
            THEN 1
        WHEN p.payment_status = 'OVERDUE'
            THEN 2
        WHEN s.shipment_status = 'DELAYED'
            THEN 3
        WHEN s.shipment_status = 'IN_TRANSIT'
            THEN 4
        ELSE 5
    END,
    outstanding_amount DESC;