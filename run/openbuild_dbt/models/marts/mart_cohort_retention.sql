
  
    
    

    create  table
      "dev"."gold"."mart_cohort_retention__dbt_tmp"
  
    as (
      -- =====================================================================
-- Model:       mart_cohort_retention
-- Layer:       Gold (marts)
-- Source:      fct_orders (gold)
-- Grain:       One row per (cohort_month, months_since_acquisition)
-- Description: Cohort retention matrix in long format. Powers the
--              heatmap visualization in the README (cohort x month grid).
--
--              The cohort denominator is derived from
--              active_users WHERE months_since_acquisition = 0, which
--              equals the number of users acquired in that cohort_month
--              (every acquired user has a first order by definition).
--
-- Right-censoring: cells exist only where at least one user was active.
-- Late cohorts (e.g. 2022-11, 2022-12) have fewer observable months
-- than the data window allows. Downstream consumers (heatmap charts)
-- must mask these gaps as needed.
-- =====================================================================

WITH active_users AS (

    SELECT
        cohort_month,
        months_since_acquisition,
        COUNT(DISTINCT user_id)                       AS active_users
    FROM "dev"."gold"."fct_orders"
    GROUP BY cohort_month, months_since_acquisition

),

cohort_size AS (

    SELECT
        cohort_month,
        active_users                                  AS cohort_size
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
ORDER BY a.cohort_month, a.months_since_acquisition
    );
  
  