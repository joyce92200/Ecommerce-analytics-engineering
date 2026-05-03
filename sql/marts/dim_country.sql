-- dim_country: gold-layer country dimension with regional rollup.
-- Source:    stg_country_lookup (silver)
-- Grain:     One row per country_code
-- Coverage:  191 valid countries from source + 2 synthetic Unclassified rows (EU, AP)
--            covering 18 orders with region codes used as country codes.

CREATE OR REPLACE TABLE dim_country AS
WITH cleaned AS (
    SELECT country_code, region
    FROM stg_country_lookup
    WHERE country_code IS NOT NULL
)
SELECT * FROM cleaned
UNION ALL
SELECT 'EU', 'Unclassified'
UNION ALL
SELECT 'AP', 'Unclassified';