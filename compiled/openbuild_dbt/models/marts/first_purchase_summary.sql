-- =====================================================================
-- Model:       first_purchase_summary
-- Layer:       Gold (marts)
-- Sources:     fct_orders (gold), dim_users (gold)
-- Grain:       One row per (loyalty_status, product_name)
-- Description: Counts users by the product of their FIRST purchase,
--              split by loyalty status at acquisition. Up to 16 rows
--              (2 loyalty values x 8 products); fewer if some combos
--              never occurred (e.g. no loyalty + bose soundsport users).
--
-- Powers README finding 1a mechanism: "loyalty disproportionately
-- recruits AirPods buyers (58.1% of loyalty first-purchases) and
-- underweights replenishables (5.7% Charging Cable Pack)."
--
-- Why this mart matters: the loyalty 3.6x retention deficit (per
-- mart_loyalty_retention) is caused by product-mix differences at
-- acquisition, not by the loyalty program itself. This mart is the
-- evidence that justifies that mechanism claim.
-- =====================================================================

SELECT
    u.loyalty_at_first_purchase                       AS loyalty_status,
    f.product_name,
    COUNT(*)                                          AS first_orders

FROM "dev"."gold"."fct_orders" f
INNER JOIN "dev"."gold"."dim_users" u USING (user_id)

WHERE f.is_first_purchase = 1
GROUP BY u.loyalty_at_first_purchase, f.product_name
ORDER BY u.loyalty_at_first_purchase, first_orders DESC