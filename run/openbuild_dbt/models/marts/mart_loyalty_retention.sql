
  
    
    

    create  table
      "dev"."gold"."mart_loyalty_retention__dbt_tmp"
  
    as (
      -- =====================================================================
-- Model:       mart_loyalty_retention
-- Layer:       Gold (marts)
-- Sources:     dim_users (gold), fct_orders (gold)
-- Grain:       One row per (cohort_month, loyalty_status, months_since_acquisition)
-- Description: Cohort retention table split by loyalty status at acquisition.
--              Powers the headline finding: loyalty members retain
--              approximately 7.4x better than non-loyalty members.
--
-- Methodology:
--   - cohort_size from dim_users: denominator fixed at acquisition
--   - active_per_period from fct_orders: counts distinct users with at
--     least one order in (cohort_month, loyalty_status, months_since_acquisition)
--   - retention_pct = 100 * active_users / cohort_size
--
-- Anti-confounder: uses loyalty_at_first_purchase, NOT current loyalty
-- status. Otherwise users who retained would skew loyalty enrollment,
-- producing reverse-causal correlation.
--
-- Note: rows exist only for (cohort, loyalty, month_N) combos where at
-- least one user was active. Months with zero retention have no row;
-- downstream consumers must handle gaps if they need them.
-- =====================================================================

WITH cohort_sizes AS (

    SELECT
        first_purchase_month                          AS cohort_month,
        loyalty_at_first_purchase                     AS loyalty_status,
        COUNT(DISTINCT user_id)                       AS cohort_size
    FROM "dev"."gold"."dim_users"
    GROUP BY first_purchase_month, loyalty_at_first_purchase

),

active_per_period AS (

    SELECT
        u.first_purchase_month                        AS cohort_month,
        u.loyalty_at_first_purchase                   AS loyalty_status,
        f.months_since_acquisition,
        COUNT(DISTINCT f.user_id)                     AS active_users
    FROM "dev"."gold"."fct_orders" f
    INNER JOIN "dev"."gold"."dim_users" u ON f.user_id = u.user_id
    GROUP BY u.first_purchase_month, u.loyalty_at_first_purchase, f.months_since_acquisition

)

SELECT
    a.cohort_month,
    a.loyalty_status,
    a.months_since_acquisition,
    a.active_users,
    c.cohort_size,
    ROUND(100.0 * a.active_users / c.cohort_size, 2)  AS retention_pct
FROM active_per_period a
INNER JOIN cohort_sizes c
    ON a.cohort_month = c.cohort_month
    AND a.loyalty_status = c.loyalty_status
ORDER BY a.cohort_month, a.loyalty_status, a.months_since_acquisition
    );
  
  