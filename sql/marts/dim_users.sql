-- dim_users: gold-layer user dimension
-- Grain: One row per user
-- Captures attributes AT FIRST PURCHASE (anti-confounder logic)
-- to enable cohort comparisons that don't suffer from reverse causality.

CREATE OR REPLACE TABLE dim_users AS
WITH first_orders AS (
    SELECT user_id, MIN(purchase_ts) AS first_purchase_ts
    FROM stg_orders GROUP BY user_id
),
first_attrs AS (
    SELECT DISTINCT s.user_id,
        FIRST_VALUE(s.loyalty_status) OVER (PARTITION BY s.user_id ORDER BY s.purchase_ts) AS loyalty_at_first_purchase,
        FIRST_VALUE(s.marketing_channel) OVER (PARTITION BY s.user_id ORDER BY s.purchase_ts) AS marketing_channel_at_first_purchase,
        FIRST_VALUE(s.account_creation_device) OVER (PARTITION BY s.user_id ORDER BY s.purchase_ts) AS device_at_first_purchase,
        FIRST_VALUE(s.usd_price) OVER (PARTITION BY s.user_id ORDER BY s.purchase_ts) AS first_purchase_aov
    FROM stg_orders s
)
SELECT
    f.user_id,
    f.first_purchase_ts,
    DATE_TRUNC('month', f.first_purchase_ts)::DATE AS first_purchase_month,
    a.loyalty_at_first_purchase,
    a.marketing_channel_at_first_purchase,
    a.device_at_first_purchase,
    a.first_purchase_aov
FROM first_orders f
INNER JOIN first_attrs a ON f.user_id = a.user_id;