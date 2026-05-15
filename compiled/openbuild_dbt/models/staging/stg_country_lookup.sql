

-- =====================================================================
-- Model:       stg_country_lookup
-- Layer:       Silver (staging)
-- Source:      bronze.country_lookup_raw
-- Grain:       One row per country_code (after deduplication)
-- Description: Cleans the country-to-region mapping.
--
-- Quality rules applied (all documented in README data quality decisions):
--   1. Drop the 1 row with NULL country_code (region='EMEA' orphan)
--   2. Dedup US (source has 2 rows: regions 'x' and 'North America')
--      via remap + SELECT DISTINCT
--   3. Map NULL or junk regions to 'Unclassified' (26 source rows)
--   4. Force US and CA to canonical 'AMER' region (overrides 'x' and
--      'North America' in source)
-- =====================================================================

WITH cleaned AS (
    SELECT
        COUNTRY_CODE AS country_code,
        CASE
            -- Canonicalize US and CA to AMER regardless of source value
            WHEN COUNTRY_CODE IN ('US', 'CA') THEN 'AMER'
            -- Defensive: catch any 'North America' or 'x' regions on
            -- non-US/CA rows (none expected, but stays robust)
            WHEN REGION IN ('North America', 'x') THEN 'AMER'
            -- NULL regions: 26 source countries lacking a region
            WHEN REGION IS NULL THEN 'Unclassified'
            -- Pass through EMEA, APAC, LATAM
            ELSE REGION
        END AS region
    FROM "dev"."bronze"."country_lookup_raw"
    -- Drop 1 orphan row with NULL country_code (documented in sources.yml)
    WHERE COUNTRY_CODE IS NOT NULL
)

SELECT DISTINCT
    country_code,
    region
FROM cleaned