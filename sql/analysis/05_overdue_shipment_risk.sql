-- ============================================================
-- 05 - Overdue Exposure Linked to Shipment Risk
-- ============================================================

SELECT
    t.trade_id,
    i.invoice_id,
    ROUND(i.invoice_amount - p.payment_amount, 2) AS outstanding_amount,
    p.payment_status,
    s.shipment_status,
    s.expected_arrival_date,
    s.actual_arrival_date,
    CASE
        WHEN s.actual_arrival_date > s.expected_arrival_date
        THEN 1
        ELSE 0
    END AS shipment_delayed
FROM trade t
JOIN invoice i
    ON t.trade_id = i.trade_id
JOIN payment p
    ON i.invoice_id = p.invoice_id
JOIN shipment s
    ON t.trade_id = s.trade_id
WHERE i.invoice_amount - p.payment_amount > 0
  AND p.payment_status = 'OVERDUE'
ORDER BY outstanding_amount DESC;