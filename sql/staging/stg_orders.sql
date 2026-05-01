-- =====================================================================
-- Model:       stg_orders
-- Layer:       Silver (staging)
-- Source:      orders_raw (bronze)
-- Grain:       One row per order
-- Description: Cleaned, typed orders. Drops rows with unparseable
--              purchase timestamps. Uses _cleaned columns; raw columns
--              retained in bronze for audit only.
-- =====================================================================
CREATE OR REPLACE TABLE stg_orders AS
SELECT -- Identifiers
    USER_ID AS user_id,
    ORDER_ID AS order_id,
    -- Timestamps (cleaned versions only)
    PURCHASE_TS_cleaned AS purchase_ts,
    DATE_TRUNC('month', PURCHASE_TS_cleaned) AS purchase_month,
    REFUND_TS_cleaned AS refund_ts,
    SHIP_TS AS ship_ts,
    DELIVERY_TS AS delivery_ts,
    CREATED_ON AS account_created_on,
    -- Order context
    PRODUCT_NAME AS product_name,
    PRODUCT_ID AS product_id,
    USD_PRICE_cleaned AS usd_price,
    PURCHASE_PLATFORM AS purchase_platform,
    COUNTRY_CODE_cleaned AS country_code,
    LOYALTY_PROGRAM AS is_loyalty_member,
    -- Derived flag for downstream refund analysis
    CASE
        WHEN REFUND_TS_cleaned IS NOT NULL THEN 1
        ELSE 0
    END AS is_refunded
FROM orders_raw
WHERE PURCHASE_TS_cleaned IS NOT NULL;
