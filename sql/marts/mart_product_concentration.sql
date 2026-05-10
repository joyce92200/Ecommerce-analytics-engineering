-- mart_product_concentration: gold-layer mart for the Pareto / concentration finding
-- Grain: One row per product
-- Computes revenue share (per-product %) and cumulative revenue share
-- across the catalog (top-N concentration metric).
-- Powers Finding 4: top 3 products = 85% of revenue (concentration risk),
-- bottom 5 = under 5% (fragmentation waste).

CREATE OR REPLACE TABLE mart_product_concentration AS
WITH product_revenue AS (
    SELECT
        product_name,
        COUNT(*) AS orders,
        SUM(usd_price) FILTER (WHERE is_refunded = 0) AS net_revenue,
        SUM(usd_price)                                 AS gross_revenue,
        AVG(usd_price) FILTER (WHERE is_refunded = 0) AS avg_aov
    FROM fct_orders
    WHERE usd_price IS NOT NULL
    GROUP BY product_name
)
SELECT
    product_name,
    orders,
    net_revenue,
    avg_aov,
    100.0 * orders / SUM(orders) OVER ()             AS pct_of_orders,
    100.0 * net_revenue / SUM(net_revenue) OVER ()   AS pct_of_revenue,
    100.0 * SUM(net_revenue) OVER (
        ORDER BY net_revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / SUM(net_revenue) OVER ()                     AS cumulative_pct_of_revenue
FROM product_revenue
ORDER BY net_revenue DESC;
