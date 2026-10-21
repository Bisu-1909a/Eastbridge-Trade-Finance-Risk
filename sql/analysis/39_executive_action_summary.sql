-- Mission 39: Executive Action Summary
-- Summarizes the management action queue by priority.

WITH action_queue AS (
    SELECT
        trade_id,
        expected_outstanding,
        fx_unhedged_exposure,
        combined_exposure,
        priority,
        action_required
    FROM (
        SELECT
            trade_id,
            expected_outstanding,
            fx_unhedged_exposure,
            combined_exposure,
            priority,
            action_required
        FROM (
            SELECT
                c.trade_id,
                c.expected_outstanding,
                c.fx_unhedged_exposure,
                c.combined_exposure,
                c.priority,
                CASE
                    WHEN c.priority = 'CRITICAL'
                        THEN 'Immediate management intervention'
                    WHEN c.priority = 'HIGH'
                        THEN 'Management review required'
                    ELSE 'Monitor'
                END AS action_required
            FROM (
                SELECT
                    f.trade_id,
                    f.outstanding_exposure AS expected_outstanding,
                    f.fx_unhedged_exposure,
                    f.outstanding_exposure + f.fx_unhedged_exposure AS combined_exposure,
                    CASE
                        WHEN f.outstanding_exposure + f.fx_unhedged_exposure >= 120000
                            THEN 'CRITICAL'
                        WHEN f.outstanding_exposure + f.fx_unhedged_exposure >= 90000
                            THEN 'HIGH'
                        WHEN f.outstanding_exposure + f.fx_unhedged_exposure >= 60000
                            THEN 'MEDIUM'
                        ELSE 'LOW'
                    END AS priority
                FROM (
                    SELECT
                        i.trade_id,
                        MAX(i.invoice_amount - COALESCE(p.payment_amount, 0)) AS outstanding_exposure,
                        MAX(
                            COALESCE(
                                fx.exposure_amount - COALESCE(h.hedged_amount, 0),
                                0
                            )
                        ) AS fx_unhedged_exposure
                    FROM invoice i
                    LEFT JOIN payment p
                        ON i.invoice_id = p.invoice_id
                    LEFT JOIN fx_exposure fx
                        ON i.trade_id = fx.trade_id
                    LEFT JOIN hedge h
                        ON fx.fx_exposure_id = h.fx_exposure_id
                    GROUP BY i.trade_id
                ) f
            ) c
        )
    )
)
SELECT
    priority,
    COUNT(*) AS trade_count,
    ROUND(SUM(combined_exposure), 2) AS total_exposure,
    ROUND(AVG(combined_exposure), 2) AS average_exposure
FROM action_queue
GROUP BY priority
ORDER BY
    CASE priority
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
        ELSE 5
    END;