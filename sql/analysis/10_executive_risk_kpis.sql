-- ============================================================
-- 10 - Executive Trade Finance Risk KPIs
-- ============================================================

WITH risk_data AS (

    SELECT
        t.trade_id,

        (i.invoice_amount - p.payment_amount)
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
)

SELECT

    COUNT(*) AS outstanding_trade_count,

    ROUND(
        SUM(outstanding_amount),
        2
    ) AS total_outstanding_exposure,

    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'OVERDUE'
                THEN outstanding_amount
                ELSE 0
            END
        ),
        2
    ) AS overdue_exposure,

    ROUND(
        SUM(
            CASE
                WHEN risk_category = 'CRITICAL_RISK'
                THEN outstanding_amount
                ELSE 0
            END
        ),
        2
    ) AS critical_exposure,

    ROUND(
        SUM(
            CASE
                WHEN risk_category = 'OPERATIONAL_RISK'
                THEN outstanding_amount
                ELSE 0
            END
        ),
        2
    ) AS operational_exposure,

    ROUND(
        SUM(
            CASE
                WHEN risk_category <> 'STANDARD'
                THEN outstanding_amount
                ELSE 0
            END
        ),
        2
    ) AS non_standard_exposure,

    ROUND(
        SUM(
            CASE
                WHEN risk_category <> 'STANDARD'
                THEN outstanding_amount
                ELSE 0
            END
        ) * 100.0
        / SUM(outstanding_amount),
        2
    ) AS non_standard_exposure_percentage

FROM risk_data;