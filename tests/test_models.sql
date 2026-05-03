-- ============================================================================
-- test_models.sql — data quality assertions for the OpenBuild medallion stack
-- ============================================================================
-- Purpose:    Schema, uniqueness, referential integrity, domain, and
--             derived-column tests. Each test is a SELECT that must
--             return 0; any non-zero result indicates a failure.
-- Coverage:   stg_orders, dim_users, fct_orders, mart_cohort_retention
-- Convention: Tests named "<model>.<column>.<test_type>", grouped by model.
--             Mirrors dbt test naming for future migration.
-- ============================================================================

-- ===== stg_orders ===========================================================

-- not_null: stg_orders.order_id
SELECT COUNT(*) AS failures FROM stg_orders WHERE order_id IS NULL;

-- unique: stg_orders.order_id
SELECT COUNT(*) - COUNT(DISTINCT order_id) AS failures FROM stg_orders;

-- not_null: stg_orders.user_id
SELECT COUNT(*) AS failures FROM stg_orders WHERE user_id IS NULL;

-- not_null: stg_orders.purchase_ts
SELECT COUNT(*) AS failures FROM stg_orders WHERE purchase_ts IS NULL;

-- accepted_values: stg_orders.purchase_platform
SELECT COUNT(*) AS failures
FROM stg_orders
WHERE purchase_platform NOT IN ('website', 'mobile app');

-- accepted_values: stg_orders.is_refunded
SELECT COUNT(*) AS failures FROM stg_orders WHERE is_refunded NOT IN (0, 1);

-- ===== dim_users ============================================================

-- unique: dim_users.user_id
SELECT COUNT(*) - COUNT(DISTINCT user_id) AS failures FROM dim_users;

-- not_null: dim_users.first_purchase_month
SELECT COUNT(*) AS failures FROM dim_users WHERE first_purchase_month IS NULL;

-- consistency: dim_users row count == stg_orders distinct users
SELECT ABS(
    (SELECT COUNT(*) FROM dim_users) -
    (SELECT COUNT(DISTINCT user_id) FROM stg_orders)
) AS failures;

-- ===== fct_orders ===========================================================

-- unique: fct_orders.order_id
SELECT COUNT(*) - COUNT(DISTINCT order_id) AS failures FROM fct_orders;

-- relationships: fct_orders.user_id -> dim_users.user_id
SELECT COUNT(*) AS failures
FROM fct_orders f
WHERE NOT EXISTS (SELECT 1 FROM dim_users u WHERE u.user_id = f.user_id);

-- consistency: fct_orders.is_first_purchase sums to dim_users count
SELECT ABS(
    (SELECT SUM(is_first_purchase) FROM fct_orders) -
    (SELECT COUNT(*) FROM dim_users)
) AS failures;

-- range: fct_orders.months_since_acquisition is non-negative
SELECT COUNT(*) AS failures FROM fct_orders WHERE months_since_acquisition < 0;

-- ===== mart_cohort_retention ================================================

-- invariant: month-0 retention must equal 100%
SELECT COUNT(*) AS failures
FROM mart_cohort_retention
WHERE months_since_acquisition = 0 AND retention_pct <> 100.00;

-- range: retention_pct must be between 0 and 100
SELECT COUNT(*) AS failures
FROM mart_cohort_retention
WHERE retention_pct < 0 OR retention_pct > 100;

-- ===== mart_refund_metrics ==================================================

-- not_null: mart_refund_metrics.product_name
SELECT COUNT(*) AS failures FROM mart_refund_metrics WHERE product_name IS NULL;

-- range: refund_rate_pct between 0 and 100
SELECT COUNT(*) AS failures
FROM mart_refund_metrics
WHERE refund_rate_pct < 0 OR refund_rate_pct > 100;

-- consistency: refunded + net = gross (within rounding tolerance)
SELECT COUNT(*) AS failures
FROM mart_refund_metrics
WHERE ABS(refunded_revenue_usd + net_revenue_usd - gross_revenue_usd) > 0.01;
