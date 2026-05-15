-- =====================================================================
-- Model:       dim_platform
-- Layer:       Gold (marts)
-- Source:      stg_orders (silver)
-- Grain:       One row per purchase_platform
-- Description: Platform dimension with rollup. Includes platform_type
--              column positioned for future enrichment (e.g. iOS/Android,
--              desktop/mobile-web).
-- =====================================================================

SELECT DISTINCT
    purchase_platform                                  AS platform_name,
    CASE
        WHEN purchase_platform = 'website'    THEN 'web'
        WHEN purchase_platform = 'mobile app' THEN 'mobile'
    END                                                AS platform_type

FROM "dev"."silver"."stg_orders"

ORDER BY platform_name