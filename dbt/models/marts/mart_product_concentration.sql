-- =====================================================================
-- Model:       mart_product_concentration
-- Layer:       Gold (marts)
-- Source:      fct_orders (gold)
-- Grain:       One row per product (8 rows total)
-- Description: Pareto / concentration analysis. Computes per-product
--              revenue share AND cumulative revenue share across the
--              ranked product list. Cumulative column powers the
--              "top N products = X% of revenue" finding.
--              Powers README Finding 4: top 3 products ~85% of revenue.
--
-- Note: 33 NULL-usd_price orders excluded at CTE level (consistent
-- with README data-quality decision: excluded from revenue aggregations).
-- =====================================================================

WITH product_revenue AS (

    SELECT
        product_name,
        COUNT(*) AS orders,
        SUM(usd_price) FILTER (WHERE is_refunded = 0) AS net_revenue,
        SUM(usd_price)                                 AS gross_revenue,
        AVG(usd_price) FILTER (WHERE is_refunded = 0) AS avg_aov
    FROM {{ ref('fct_orders') }}
    WHERE usd_price IS NOT NULL
    GROUP BY product_name

)

SELECT
    product_name,
    orders,
    net_revenue,
    avg_aov,
    100.0 * orders      / SUM(orders)      OVER ()                       AS pct_of_orders,
    100.0 * net_revenue / SUM(net_revenue) OVER ()                       AS pct_of_revenue,
    100.0 * SUM(net_revenue) OVER (
        ORDER BY net_revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / SUM(net_revenue) OVER ()                                         AS cumulative_pct_of_revenue
FROM product_revenue
ORDER BY net_revenue DESC
