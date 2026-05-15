-- =====================================================================
-- Model:       mart_channel_revenue
-- Layer:       Gold (marts)
-- Source:      fct_orders (gold)
-- Grain:       One row per (purchase_month, purchase_platform)
-- Description: Monthly revenue by platform with within-month share.
--              Supports channel-mix and platform-trend analysis on
--              the dashboard.
-- =====================================================================

WITH monthly AS (

    SELECT
        purchase_month,
        purchase_platform,
        COUNT(*)                                                          AS orders,
        ROUND(SUM(usd_price), 2)                                          AS gross_revenue_usd,
        ROUND(SUM(CASE WHEN is_refunded = 0 THEN usd_price ELSE 0 END), 2) AS net_revenue_usd
    FROM {{ ref('fct_orders') }}
    GROUP BY purchase_month, purchase_platform

),

monthly_total AS (

    SELECT
        purchase_month,
        SUM(net_revenue_usd) AS total_month_net_revenue
    FROM monthly
    GROUP BY purchase_month

)

SELECT
    m.purchase_month,
    m.purchase_platform,
    m.orders,
    m.gross_revenue_usd,
    m.net_revenue_usd,
    ROUND(100.0 * m.net_revenue_usd / NULLIF(t.total_month_net_revenue, 0), 2) AS share_of_month_pct

FROM monthly m
INNER JOIN monthly_total t USING (purchase_month)
ORDER BY m.purchase_month, m.purchase_platform
