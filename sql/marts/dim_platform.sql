-- dim_platform: gold-layer platform dimension.
-- Source: stg_orders (silver)
-- Grain:  One row per purchase_platform
-- Note:   platform_type column groups platforms into broader categories,
--         positioned for future enrichment (iOS/Android, desktop/mobile-web).

CREATE OR REPLACE TABLE dim_platform AS
SELECT DISTINCT
    purchase_platform AS platform_name,
    CASE
        WHEN purchase_platform = 'website' THEN 'web'
        WHEN purchase_platform = 'mobile app' THEN 'mobile'
    END AS platform_type
FROM stg_orders
ORDER BY platform_name;