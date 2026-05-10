-- dim_product: gold-layer product dimension
-- Grain: One row per product_name
-- Note: source product_id is opaque (4-char hash) and not used downstream;
-- product_name is the canonical identifier in the analytical layer.

CREATE OR REPLACE TABLE dim_product AS
SELECT DISTINCT product_name
FROM stg_orders
WHERE product_name IS NOT NULL
ORDER BY product_name;