-- =====================================================================
-- Model:       dim_country
-- Layer:       Gold (marts)
-- Source:      stg_country_lookup (silver)
-- Grain:       One row per country_code
-- Description: Country dimension with regional rollup. Includes 2 synthetic
--              rows ("EU", "AP") to absorb 18 orders that use region codes
--              as country codes (documented in README data quality).
--              Coverage: 191 source countries + 2 synthetic = 193 rows.
-- =====================================================================

WITH source_with_synthetic AS (

    SELECT country_code, region
    FROM {{ ref('stg_country_lookup') }}
    WHERE country_code IS NOT NULL

    UNION ALL

    SELECT 'EU' AS country_code, 'Unclassified' AS region

    UNION ALL

    SELECT 'AP' AS country_code, 'Unclassified' AS region

)

SELECT
    country_code,
    region
FROM source_with_synthetic
