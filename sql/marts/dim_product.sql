-- dim_product: gold-layer product dimension.
-- Source: stg_orders (silver)
-- Grain:  One row per product_name
-- Note:   product_id varies across orders for some products; MIN(product_id)
--         taken as the deterministic canonical hash.

CREATE OR REPLACE TABLE dim_product AS
SELECT
    product_name,
    MIN(product_id) AS product_id
FROM stg_orders
GROUP BY product_name
ORDER BY product_name;