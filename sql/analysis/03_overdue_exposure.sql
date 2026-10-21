-- ============================================================
-- 03 - Overdue Trade Finance Exposure
-- ============================================================

SELECT
    COUNT(*) AS overdue_invoices,
    ROUND(SUM(i.invoice_amount), 2) AS overdue_invoiced_amount,
    ROUND(SUM(p.payment_amount), 2) AS overdue_paid_amount,
    ROUND(SUM(i.invoice_amount - p.payment_amount), 2) AS overdue_outstanding_amount
FROM invoice i
JOIN payment p
    ON i.invoice_id = p.invoice_id
WHERE i.invoice_amount - p.payment_amount > 0
  AND p.payment_status = 'OVERDUE';