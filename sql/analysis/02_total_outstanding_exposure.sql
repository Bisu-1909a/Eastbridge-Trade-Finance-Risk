-- ============================================================
-- 02 - Total Outstanding Trade Finance Exposure
-- ============================================================

SELECT
    COUNT(*) AS outstanding_invoices,
    ROUND(SUM(i.invoice_amount), 2) AS total_invoiced_amount,
    ROUND(SUM(p.payment_amount), 2) AS total_paid_amount,
    ROUND(SUM(i.invoice_amount - p.payment_amount), 2) AS total_outstanding_amount
FROM invoice i
JOIN payment p
    ON i.invoice_id = p.invoice_id
WHERE i.invoice_amount - p.payment_amount > 0;