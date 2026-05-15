-- =====================================================================
-- Model:       dim_product
-- Layer:       Gold (marts)
-- Source:      stg_orders (silver)
-- Grain:       One row per product_name
-- Description: Product dimension. product_name is the canonical identifier
--              in the analytical layer (source product_id is an opaque
--              4-char hash, not used downstream).
-- =====================================================================

SELECT DISTINCT
    product_name
FROM "dev"."silver"."stg_orders"
WHERE product_name IS NOT NULL
ORDER BY product_name