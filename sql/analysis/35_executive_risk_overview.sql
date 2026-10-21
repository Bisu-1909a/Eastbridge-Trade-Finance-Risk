WITH risk_data AS (
    SELECT
        trade_id,
        combined_exposure,
        risk_priority
    FROM (
        SELECT
            trade_id,
            combined_exposure,
            risk_priority
        FROM (
            SELECT
                trade_id,
                financial_exposure,
                fx_exposure,
                combined_exposure,
                CASE
                    WHEN combined_exposure >= 120000 THEN 'CRITICAL'
                    WHEN combined_exposure >= 90000 THEN 'HIGH'
                    WHEN combined_exposure >= 60000 THEN 'MEDIUM'
                    ELSE 'LOW'
                END AS risk_priority
            FROM (
                SELECT
                    trade_id,
                    financial_exposure,
                    fx_exposure,
                    financial_exposure + fx_exposure AS combined_exposure
                FROM (
                    SELECT
                        f.trade_id,
                        f.outstanding_amount AS financial_exposure,
                        COALESCE(x.unhedged_exposure, 0) AS fx_exposure
                    FROM (
                        SELECT
                            i.trade_id,
                            MAX(i.invoice_amount - COALESCE(p.payment_amount, 0)) AS outstanding_amount
                        FROM invoice i
                        LEFT JOIN payment p
                            ON i.invoice_id = p.invoice_id
                        WHERE i.invoice_amount - COALESCE(p.payment_amount, 0) > 0
                        GROUP BY i.trade_id
                    ) f
                    LEFT JOIN (
                        SELECT
                            fx.trade_id,
                            fx.exposure_amount - COALESCE(h.hedged_amount, 0) AS unhedged_exposure
                        FROM fx_exposure fx
                        LEFT JOIN hedge h
                            ON fx.fx_exposure_id = h.fx_exposure_id
                    ) x
                        ON f.trade_id = x.trade_id
                )
            )
        )
    )
)

SELECT
    COUNT(*) AS trades_with_exposure,

    ROUND(SUM(combined_exposure), 2) AS total_combined_exposure,

    ROUND(SUM(
        CASE
            WHEN risk_priority IN ('CRITICAL', 'HIGH')
            THEN combined_exposure
            ELSE 0
        END
    ), 2) AS critical_high_exposure,

    ROUND(SUM(
        CASE
            WHEN risk_priority = 'CRITICAL'
            THEN combined_exposure
            ELSE 0
        END
    ), 2) AS critical_exposure,

    ROUND(SUM(
        CASE
            WHEN risk_priority = 'HIGH'
            THEN combined_exposure
            ELSE 0
        END
    ), 2) AS high_exposure,

    ROUND(SUM(
        CASE
            WHEN risk_priority = 'MEDIUM'
            THEN combined_exposure
            ELSE 0
        END
    ), 2) AS medium_exposure,

    ROUND(SUM(
        CASE
            WHEN risk_priority = 'LOW'
            THEN combined_exposure
            ELSE 0
        END
    ), 2) AS low_exposure,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN risk_priority IN ('CRITICAL', 'HIGH')
                THEN combined_exposure
                ELSE 0
            END
        )
        / NULLIF(SUM(combined_exposure), 0),
        2
    ) AS critical_high_exposure_pct,

    SUM(
        CASE
            WHEN risk_priority IN ('CRITICAL', 'HIGH')
            THEN 1
            ELSE 0
        END
    ) AS management_attention_trades

FROM risk_data;