-- dim_users: gold-layer user dimension. One row per user.
-- Source: stg_orders. Strategy: rank user's orders, snapshot rank=1 attributes.

CREATE OR REPLACE TABLE dim_users AS
WITH ranked_orders AS (
    SELECT
        user_id,
        purchase_ts,
        purchase_month,
        country_code,
        purchase_platform,
        product_name,
        is_loyalty_member,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY purchase_ts ASC, order_id ASC
        ) AS order_rank
    FROM stg_orders
)
SELECT
    user_id,
    purchase_ts          AS first_purchase_date,
    purchase_month       AS first_purchase_month,
    country_code         AS first_purchase_country,
    purchase_platform    AS first_purchase_platform,
    product_name         AS first_purchase_product,
    is_loyalty_member    AS loyalty_at_first_purchase
FROM ranked_orders
WHERE order_rank = 1;