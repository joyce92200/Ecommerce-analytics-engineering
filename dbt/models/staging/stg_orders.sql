{{
  config(
    materialized='view',
    schema='silver'
  )
}}

-- =====================================================================
-- Model:       stg_orders
-- Layer:       Silver (staging)
-- Source:      bronze.orders_raw
-- Grain:       One row per order
-- Description: Cleaned, typed orders. Casts VARCHAR bronze columns to
--              proper types. Rows with unparseable purchase timestamps
--              are dropped (~3 rows per README data-quality decisions).
--              Uses _cleaned columns where source provides them; raw
--              variants stay in bronze for audit lineage.
-- =====================================================================

SELECT
    -- Identifiers
    USER_ID                                                AS user_id,
    ORDER_ID                                               AS order_id,

    -- Timestamps (cleaned, with safe casting)
    TRY_CAST(PURCHASE_TS_cleaned AS TIMESTAMP)             AS purchase_ts,
    DATE_TRUNC('month', TRY_CAST(PURCHASE_TS_cleaned AS TIMESTAMP))
                                                           AS purchase_month,
    TRY_CAST(REFUND_TS AS TIMESTAMP)                       AS refund_ts,
    TRY_CAST(SHIP_TS AS TIMESTAMP)                         AS ship_ts,
    TRY_CAST(DELIVERY_TS AS TIMESTAMP)                     AS delivery_ts,
    TRY_CAST(CREATED_ON AS TIMESTAMP)                      AS account_created_on,

    -- Order context
    PRODUCT_NAME                                           AS product_name,
    PRODUCT_ID                                              AS product_id,
    TRY_CAST(USD_PRICE_cleaned AS DOUBLE)                  AS usd_price,
    PURCHASE_PLATFORM                                      AS purchase_platform,
    MARKETING_CHANNEL_cleaned                              AS marketing_channel,
    NULLIF(ACCOUNT_CREATION_METHOD_cleaned, 'NaN')         AS account_creation_device,
    COUNTRY_CODE_cleaned                                   AS country_code,
    CAST(LOYALTY_PROGRAM AS INTEGER)                       AS loyalty_status,

    -- Derived flag for downstream refund analysis
    CASE
        WHEN REFUND_TS IS NOT NULL AND TRIM(REFUND_TS) <> '' THEN 1
        ELSE 0
    END                                                    AS is_refunded

FROM {{ source('bronze', 'orders_raw') }}

-- Drop rows where purchase timestamp can't be parsed.
-- The README documents this at 3 rows (0.003%); the test we'll add
-- against stg_orders verifies the count hasn't drifted.
WHERE TRY_CAST(PURCHASE_TS_cleaned AS TIMESTAMP) IS NOT NULL
