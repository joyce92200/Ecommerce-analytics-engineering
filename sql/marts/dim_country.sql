-- dim_country: gold-layer country dimension with regional rollup.
-- Source:    stg_country_lookup (silver)
-- Grain:     One row per country_code
-- Coverage:  191 valid countries from source + 2 synthetic Unclassified rows (EU, AP)
--            covering 18 orders that use region codes as country codes.

CREATE OR REPLACE TABLE dim_country AS
WITH source_with_synthetic AS (
    SELECT country_code, region FROM stg_country_lookup
    WHERE country_code IS NOT NULL
    UNION ALL
    SELECT 'EU', 'Unclassified'
    UNION ALL
    SELECT 'AP', 'Unclassified'
)
SELECT country_code, region FROM source_with_synthetic;