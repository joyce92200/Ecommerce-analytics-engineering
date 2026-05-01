-- ============================================================================
-- fct_orders — gold-layer order fact table
-- ============================================================================
-- Purpose:  One row per order, enriched with user-level cohort context.
--           Powers cohort, refund, revenue, and channel analyses.
-- Source:   stg_orders (silver), dim_users (gold)
-- Grain:    One row per order_id
-- Strategy: Inner join to dim_users for cohort enrichment;
--           deterministic ROW_NUMBER for user_order_seq using
--           (purchase_ts, order_id) as ordering key.
-- ============================================================================

CREATE OR REPLACE TABLE fct_orders AS
WITH ranked AS (
    SELECT
        o.*,
        u.first_purchase_date,
        u.first_purchase_month AS cohort_month,
        DATE_DIFF('month', u.first_purchase_month, o.purchase_month) AS months_since_acquisition,
        ROW_NUMBER() OVER (
            PARTITION BY o.user_id
            ORDER BY o.purchase_ts ASC, o.order_id ASC
        ) AS user_order_seq
    FROM stg_orders o
    INNER JOIN dim_users u USING (user_id)
)
SELECT
    order_id,
    user_id,
    purchase_ts,
    purchase_month,
    refund_ts,
    is_refunded,
    product_name,
    product_id,
    usd_price,
    purchase_platform,
    country_code,
    is_loyalty_member,
    first_purchase_date,
    cohort_month,
    months_since_acquisition,
    user_order_seq,
    CASE WHEN user_order_seq = 1 THEN 1 ELSE 0 END AS is_first_purchase
FROM ranked;
