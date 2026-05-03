-- mart_refund_metrics: gold-layer refund analysis by product × country.
-- Source: fct_orders. Grain: (product_name, country_code).
-- Surfaces both rate-based (refund_rate_pct) and value-based
-- (refunded_revenue_pct) angles for actionable refund analysis.

CREATE OR REPLACE TABLE mart_refund_metrics AS
SELECT
    product_name,
    country_code,

    COUNT(*)                                                         AS orders,
    SUM(is_refunded)                                                 AS refunds,
    ROUND(100.0 * SUM(is_refunded) / COUNT(*), 2)                    AS refund_rate_pct,

    ROUND(SUM(usd_price), 2)                                         AS gross_revenue_usd,
    ROUND(SUM(CASE WHEN is_refunded = 1 THEN usd_price ELSE 0 END), 2) AS refunded_revenue_usd,
    ROUND(SUM(CASE WHEN is_refunded = 0 THEN usd_price ELSE 0 END), 2) AS net_revenue_usd,

    ROUND(
        100.0 * SUM(CASE WHEN is_refunded = 1 THEN usd_price ELSE 0 END)
              / NULLIF(SUM(usd_price), 0),
        2
    ) AS refunded_revenue_pct

FROM fct_orders
GROUP BY product_name, country_code;