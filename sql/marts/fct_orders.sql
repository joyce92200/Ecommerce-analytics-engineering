-- fct_orders: gold-layer order-grain fact table
-- Grain: One row per order
-- Joins to dim_users to add cohort attribution and order sequencing.
-- Anti-confounder: cohort_month derives from user's first_purchase_month, not order's own month.

CREATE OR REPLACE TABLE fct_orders AS
WITH ranked AS (
    SELECT
        o.*,
        DATE_TRUNC('month', o.purchase_ts)::DATE AS purchase_month,
        u.first_purchase_ts,
        u.first_purchase_month AS cohort_month,
        DATE_DIFF('month',
                  u.first_purchase_month,
                  DATE_TRUNC('month', o.purchase_ts)::DATE
        ) AS months_since_acquisition,
        ROW_NUMBER() OVER (
            PARTITION BY o.user_id
            ORDER BY o.purchase_ts ASC, o.order_id ASC
        ) AS user_order_seq
    FROM stg_orders o
    INNER JOIN dim_users u USING (user_id)
)
SELECT
    order_id, user_id, purchase_ts, purchase_month, refund_ts, is_refunded,
    product_name, usd_price, purchase_platform, country_code, loyalty_status,
    first_purchase_ts, cohort_month, months_since_acquisition, user_order_seq,
    CASE WHEN user_order_seq = 1 THEN 1 ELSE 0 END AS is_first_purchase
FROM ranked;