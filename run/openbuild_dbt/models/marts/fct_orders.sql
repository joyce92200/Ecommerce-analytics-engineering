
  
    
    

    create  table
      "dev"."gold"."fct_orders__dbt_tmp"
  
    as (
      -- =====================================================================
-- Model:       fct_orders
-- Layer:       Gold (marts)
-- Sources:     stg_orders (silver), dim_users (gold)
-- Grain:       One row per order
-- Description: Order-grain fact table. Joins to dim_users to attach
--              cohort attribution (cohort_month from user first purchase
--              month, NOT this order's month — anti-confounder logic).
--              Includes derived columns for downstream marts:
--                - purchase_month: month of THIS order
--                - cohort_month: user's first-purchase month (cohort key)
--                - months_since_acquisition: order_month - cohort_month
--                - user_order_seq: 1-based rank of order within user
--                - is_first_purchase: 1 if user_order_seq = 1
-- =====================================================================

WITH ranked AS (

    SELECT
        o.*,
        DATE_TRUNC('month', o.purchase_ts)::DATE        AS purchase_month,
        u.first_purchase_ts,
        u.first_purchase_month                          AS cohort_month,
        DATE_DIFF('month',
                  u.first_purchase_month,
                  DATE_TRUNC('month', o.purchase_ts)::DATE
        )                                               AS months_since_acquisition,
        ROW_NUMBER() OVER (
            PARTITION BY o.user_id
            ORDER BY o.purchase_ts ASC, o.order_id ASC
        )                                               AS user_order_seq
    FROM "dev"."silver"."stg_orders" o
    INNER JOIN "dev"."gold"."dim_users" u USING (user_id)

)

SELECT
    order_id,
    user_id,
    purchase_ts,
    purchase_month,
    refund_ts,
    is_refunded,
    product_name,
    usd_price,
    purchase_platform,
    country_code,
    loyalty_status,
    first_purchase_ts,
    cohort_month,
    months_since_acquisition,
    user_order_seq,
    CASE WHEN user_order_seq = 1 THEN 1 ELSE 0 END      AS is_first_purchase

FROM ranked
    );
  
  