
  
    
    

    create  table
      "dev"."gold"."dim_users__dbt_tmp"
  
    as (
      -- =====================================================================
-- Model:       dim_users
-- Layer:       Gold (marts)
-- Source:      stg_orders (silver)
-- Grain:       One row per user
-- Description: User dimension with attributes SNAPSHOTTED AT FIRST
--              PURCHASE. This is the single most important methodological
--              choice in the project: by fixing loyalty, marketing channel,
--              and device to their values at the user's first order, we
--              avoid the reverse-causality trap where current-state
--              attributes are contaminated by retention outcomes.
--              Reference: README "Data Quality Decisions" section.
--
--              Tie-breaking: when a user has multiple orders sharing the
--              same earliest purchase_ts (common because bronze timestamps
--              are at midnight), we deterministically pick the row with
--              the lexically smallest order_id.
-- =====================================================================

WITH first_orders AS (

    -- Each user's earliest purchase timestamp
    SELECT
        user_id,
        MIN(purchase_ts) AS first_purchase_ts
    FROM "dev"."silver"."stg_orders"
    GROUP BY user_id

),

first_attrs AS (

    -- For each user, capture loyalty/channel/device/price from their
    -- earliest order. Tie-broken on order_id for determinism.
    SELECT DISTINCT
        user_id,
        FIRST_VALUE(loyalty_status)
            OVER (PARTITION BY user_id ORDER BY purchase_ts, order_id) AS loyalty_at_first_purchase,
        FIRST_VALUE(marketing_channel)
            OVER (PARTITION BY user_id ORDER BY purchase_ts, order_id) AS marketing_channel_at_first_purchase,
        FIRST_VALUE(account_creation_device)
            OVER (PARTITION BY user_id ORDER BY purchase_ts, order_id) AS device_at_first_purchase,
        FIRST_VALUE(usd_price)
            OVER (PARTITION BY user_id ORDER BY purchase_ts, order_id) AS first_purchase_aov
    FROM "dev"."silver"."stg_orders"

)

SELECT
    f.user_id,
    f.first_purchase_ts,
    DATE_TRUNC('month', f.first_purchase_ts)::DATE  AS first_purchase_month,
    a.loyalty_at_first_purchase,
    a.marketing_channel_at_first_purchase,
    a.device_at_first_purchase,
    a.first_purchase_aov

FROM first_orders f
INNER JOIN first_attrs a USING (user_id)
    );
  
  