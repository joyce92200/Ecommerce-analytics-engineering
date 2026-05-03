-- stg_country_lookup: silver-layer country lookup cleaning.
-- Source:        country_lookup_raw (bronze)
-- Grain:         One row per country_code (after deduplication)
-- Quality rules: deduplicates US (had 2 source rows: 'x' and 'North America'),
--                maps NULL/junk regions to canonical values, classifies CA as AMER.

CREATE OR REPLACE TABLE stg_country_lookup AS
WITH deduped AS (
    SELECT
        COUNTRY_CODE AS country_code,
        CASE
            WHEN COUNTRY_CODE = 'US' THEN 'AMER'
            WHEN COUNTRY_CODE = 'CA' THEN 'AMER'
            WHEN REGION IN ('x', 'North America') THEN 'AMER'
            WHEN REGION IS NULL THEN 'Unclassified'
            ELSE REGION
        END AS region
    FROM country_lookup_raw
)
SELECT DISTINCT country_code, region
FROM deduped;