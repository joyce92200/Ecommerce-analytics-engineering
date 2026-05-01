-- mart_cohort_retention: gold-layer retention matrix (long format).
-- Source: fct_orders. Grain: (cohort_month, months_since_acquisition).
-- Note: right-censored cells included; consumers must mask as needed.

CREATE OR REPLACE TABLE mart_cohort_retention AS
WITH active_users AS (
    SELECT
        cohort_month,
        months_since_acquisition,
        COUNT(DISTINCT user_id) AS active_users
    FROM fct_orders
    GROUP BY cohort_month, months_since_acquisition
),
cohort_size AS (
    SELECT
        cohort_month,
        active_users AS cohort_size
    FROM active_users
    WHERE months_since_acquisition = 0
)
SELECT
    a.cohort_month,
    a.months_since_acquisition,
    a.active_users,
    s.cohort_size,
    ROUND(a.active_users * 100.0 / s.cohort_size, 2) AS retention_pct
FROM active_users a
INNER JOIN cohort_size s USING (cohort_month)
ORDER BY a.cohort_month, a.months_since_acquisition;