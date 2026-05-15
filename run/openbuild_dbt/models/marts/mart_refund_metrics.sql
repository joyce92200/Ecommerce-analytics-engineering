
  
    
    

    create  table
      "dev"."gold"."mart_refund_metrics__dbt_tmp"
  
    as (
      -- =====================================================================
-- Model:       mart_refund_metrics
-- Layer:       Gold (marts)
-- Source:      fct_orders (gold)
-- Grain:       One row per (product_name, country_code)
-- Description: Refund analysis with both count-based (refund_rate_pct)
--              and value-based (refunded_revenue_pct) angles. Dual
--              perspective surfaces cases where refund rate doesn't
--              tell the same story as refund value.
--
-- Note: ~154 orders have NULL country_code; they appear as rows
-- where country_code IS NULL in this output (one per product).
-- =====================================================================

SELECT
    product_name,
    country_code,
    COUNT(*)                                                         AS orders,
    SUM(is_refunded)                                                 AS refunds,
    ROUND(100.0 * SUM(is_refunded) / COUNT(*), 2)                    AS refund_rate_pct,
    ROUND(SUM(usd_price), 2)                                         AS gross_revenue_usd,
    ROUND(SUM(CASE WHEN is_refunded = 1 THEN usd_price ELSE 0 END), 2) AS refunded_revenue_usd,
    ROUND(SUM(CASE WHEN is_refunded = 0 THEN usd_price ELSE 0 END), 2) AS net_revenue_usd,
    ROUND(
        100.0 * SUM(CASE WHEN is_refunded = 1 THEN usd_price ELSE 0 END)
              / NULLIF(SUM(usd_price), 0),
        2
    )                                                                AS refunded_revenue_pct

FROM "dev"."gold"."fct_orders"
GROUP BY product_name, country_code
    );
  
  