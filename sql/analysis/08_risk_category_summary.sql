-- ============================================================
-- 08 - Trade Risk Category Summary
-- ============================================================

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

    COUNT(*) AS trade_count,

    ROUND(
        SUM(i.invoice_amount - p.payment_amount),
        2
    ) AS total_outstanding_exposure

FROM trade t

JOIN invoice i
    ON t.trade_id = i.trade_id

JOIN payment p
    ON i.invoice_id = p.invoice_id

JOIN shipment s
    ON t.trade_id = s.trade_id

WHERE i.invoice_amount - p.payment_amount > 0

GROUP BY risk_category

ORDER BY
    CASE risk_category
        WHEN 'CRITICAL_RISK' THEN 1
        WHEN 'FINANCIAL_RISK' THEN 2
        WHEN 'OPERATIONAL_RISK' THEN 3
        WHEN 'MONITOR' THEN 4
        WHEN 'STANDARD' THEN 5
    END;