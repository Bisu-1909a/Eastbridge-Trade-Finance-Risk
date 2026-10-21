-- ============================================================
-- EastBridge Trade Finance Risk
-- Mission 58 — Financial Exposure Audit
--
-- Purpose:
-- Identify why financial exposure differs between the
-- executive validation and the receivable-based analysis.
--
-- This audit compares:
--
--   A. Expected profit / financial exposure
--   B. Outstanding customer receivable
--
-- Grain:
-- 1 row per trade
-- ============================================================

WITH expected_financial AS (

    SELECT
        trade_id,

        expected_revenue
        - expected_procurement_cost
        - expected_operational_cost
            AS expected_financial_exposure

    FROM trade
),

receivable_financial AS (

    SELECT
        i.trade_id,

        MAX(i.invoice_amount)
        - COALESCE(
            SUM(p.payment_amount),
            0
        ) AS outstanding_receivable

    FROM invoice i

    LEFT JOIN payment p
        ON i.invoice_id = p.invoice_id

    GROUP BY
        i.trade_id

    HAVING
        outstanding_receivable > 0
),

comparison AS (

    SELECT

        e.trade_id,

        e.expected_financial_exposure,

        COALESCE(
            r.outstanding_receivable,
            0
        ) AS outstanding_receivable,

        CASE
            WHEN r.trade_id IS NOT NULL
                THEN 'HAS_OUTSTANDING_RECEIVABLE'

            ELSE 'NO_OUTSTANDING_RECEIVABLE'
        END AS receivable_status

    FROM expected_financial e

    LEFT JOIN receivable_financial r
        ON e.trade_id = r.trade_id
)

SELECT
    'TOTAL TRADES' AS audit_metric,
    COUNT(*) AS value
FROM comparison

UNION ALL

SELECT
    'EXPECTED FINANCIAL EXPOSURE',
    ROUND(
        SUM(expected_financial_exposure),
        2
    )
FROM comparison

UNION ALL

SELECT
    'OUTSTANDING RECEIVABLE EXPOSURE',
    ROUND(
        SUM(outstanding_receivable),
        2
    )
FROM comparison

UNION ALL

SELECT
    'TRADES WITH OUTSTANDING RECEIVABLE',
    COUNT(*)
FROM comparison
WHERE receivable_status =
    'HAS_OUTSTANDING_RECEIVABLE'

UNION ALL

SELECT
    'TRADES WITHOUT OUTSTANDING RECEIVABLE',
    COUNT(*)
FROM comparison
WHERE receivable_status =
    'NO_OUTSTANDING_RECEIVABLE'

UNION ALL

SELECT
    'EXPECTED EXPOSURE ABOVE RECEIVABLE',
    ROUND(
        SUM(
            CASE
                WHEN expected_financial_exposure
                    > outstanding_receivable
                THEN expected_financial_exposure
                    - outstanding_receivable
                ELSE 0
            END
        ),
        2
    )
FROM comparison

UNION ALL

SELECT
    'RECEIVABLE ABOVE EXPECTED EXPOSURE',
    ROUND(
        SUM(
            CASE
                WHEN outstanding_receivable
                    > expected_financial_exposure
                THEN outstanding_receivable
                    - expected_financial_exposure
                ELSE 0
            END
        ),
        2
    )
FROM comparison;