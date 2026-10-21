-- ============================================================
-- 01 - Outstanding Trade Finance Exposure
-- ============================================================

SELECT
    t.trade_id,
    t.customer_id,
    i.invoice_id,
    i.invoice_amount,
    p.payment_amount,
    ROUND(i.invoice_amount - p.payment_amount, 2) AS outstanding_amount,
    i.invoice_status,
    p.payment_status
FROM trade t
JOIN invoice i
    ON t.trade_id = i.trade_id
JOIN payment p
    ON i.invoice_id = p.invoice_id
WHERE i.invoice_amount - p.payment_amount > 0
ORDER BY outstanding_amount DESC;

