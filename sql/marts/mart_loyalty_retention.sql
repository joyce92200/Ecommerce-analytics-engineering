-- mart_loyalty_retention: cohort retention split by loyalty membership at acquisition.
-- Source:    dim_users (loyalty_at_first_purchase), fct_orders (months_since_acquisition)
-- Grain:     One row per (cohort_month, loyalty_status, months_since_acquisition)
-- Purpose:   Tests whether loyalty membership at acquisition correlates with month-N retention.
-- Anti-confounder: Uses loyalty_at_first_purchase (not current loyalty status) to avoid
--                  reverse causality (users who retained → joined loyalty later).

CREATE OR REPLACE TABLE mart_loyalty_retention AS
WITH cohort_sizes AS (
    SELECT
        first_purchase_month AS cohort_month,
        loyalty_at_first_purchase AS loyalty_status,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM dim_users
    GROUP BY first_purchase_month, loyalty_at_first_purchase
),
active_per_period AS (
    SELECT
        u.first_purchase_month AS cohort_month,
        u.loyalty_at_first_purchase AS loyalty_status,
        f.months_since_acquisition,
        COUNT(DISTINCT f.user_id) AS active_users
    FROM fct_orders f
    INNER JOIN dim_users u ON f.user_id = u.user_id
    GROUP BY u.first_purchase_month, u.loyalty_at_first_purchase, f.months_since_acquisition
)
SELECT
    a.cohort_month,
    a.loyalty_status,
    a.months_since_acquisition,
    a.active_users,
    c.cohort_size,
    ROUND(100.0 * a.active_users / c.cohort_size, 2) AS retention_pct
FROM active_per_period a
INNER JOIN cohort_sizes c
    ON a.cohort_month = c.cohort_month
    AND a.loyalty_status = c.loyalty_status
ORDER BY a.cohort_month, a.loyalty_status, a.months_since_acquisition;