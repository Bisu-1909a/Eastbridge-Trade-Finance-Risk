-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 61 — Final SQL Integrity Check
--
-- Purpose:
-- Confirm the core executive datasets are internally
-- consistent before Power BI development.
-- ============================================================

SELECT
    'TOTAL TRADES' AS validation_metric,
    COUNT(*) AS value
FROM trade

UNION ALL

SELECT
    'TRADES WITH INVOICE',
    COUNT(DISTINCT trade_id)
FROM invoice

UNION ALL

SELECT
    'TRADES WITH FX EXPOSURE',
    COUNT(DISTINCT trade_id)
FROM fx_exposure

UNION ALL

SELECT
    'TOTAL INVOICED AMOUNT',
    ROUND(
        SUM(invoice_amount),
        2
    )
FROM invoice

UNION ALL

SELECT
    'TOTAL PAYMENTS',
    ROUND(
        COALESCE(
            SUM(payment_amount),
            0
        ),
        2
    )
FROM payment

UNION ALL

SELECT
    'TOTAL FX EXPOSURE',
    ROUND(
        SUM(exposure_amount),
        2
    )
FROM fx_exposure

UNION ALL

SELECT
    'TOTAL HEDGED AMOUNT',
    ROUND(
        COALESCE(
            SUM(hedged_amount),
            0
        ),
        2
    )
FROM hedge;