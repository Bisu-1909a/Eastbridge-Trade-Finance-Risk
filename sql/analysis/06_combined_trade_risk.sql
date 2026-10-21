-- ============================================================
-- 06 - Combined Financial + Operational Trade Risk
-- ============================================================

SELECT
    t.trade_id,

    ROUND(i.invoice_amount - p.payment_amount, 2)
        AS outstanding_amount,

    p.payment_status,

    s.shipment_status,

    CASE
        WHEN s.shipment_status = 'DELAYED'
            THEN 'OPERATIONAL_RISK'

        WHEN s.shipment_status = 'IN_TRANSIT'
            THEN 'MONITOR'

        WHEN p.payment_status = 'OVERDUE'
            THEN 'FINANCIAL_RISK'

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

ORDER BY outstanding_amount DESC;