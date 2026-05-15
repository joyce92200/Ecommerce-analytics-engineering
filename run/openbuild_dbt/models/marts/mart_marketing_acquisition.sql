
  
    
    

    create  table
      "dev"."gold"."mart_marketing_acquisition__dbt_tmp"
  
    as (
      -- =====================================================================
-- Model:       mart_marketing_acquisition
-- Layer:       Gold (marts)
-- Source:      dim_users (gold)
-- Grain:       One row per (marketing_channel, loyalty_status)
-- Description: Shows which marketing channels disproportionately recruit
--              loyalty members and the AOV signal at acquisition by
--              channel/loyalty combination. Powers README finding 1b:
--              email channel concentrates loyalty signups AND low-AOV
--              buyers (suggesting a channel-mix confounder behind the
--              headline loyalty retention finding).
--
-- Note: dim_users provides snapshot-at-first-purchase values. Filtering
-- first_purchase_aov IS NOT NULL drops 27 users whose first order had
-- NULL price, consistent with README data-quality decisions.
-- The ~1,153 users with NULL marketing_channel cluster into a NULL row.
-- =====================================================================

SELECT
    marketing_channel_at_first_purchase                              AS marketing_channel,
    loyalty_at_first_purchase                                        AS loyalty_status,
    COUNT(*)                                                         AS users_acquired,
    AVG(first_purchase_aov)                                          AS avg_first_aov,
    SUM(first_purchase_aov)                                          AS total_first_revenue,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER (
        PARTITION BY marketing_channel_at_first_purchase
    )                                                                AS pct_within_channel

FROM "dev"."gold"."dim_users"
WHERE first_purchase_aov IS NOT NULL
GROUP BY marketing_channel_at_first_purchase, loyalty_at_first_purchase
ORDER BY marketing_channel, loyalty_status
    );
  
  