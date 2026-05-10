-- mart_marketing_acquisition: gold-layer mart for the email-channel finding
-- Grain: One row per (marketing_channel_at_first_purchase × loyalty_at_first_purchase)
-- Reveals which marketing channels disproportionately recruit loyalty members
-- and the AOV signal at acquisition by channel/loyalty combination.
-- Powers Finding 1b: email channel concentrates loyalty signups AND low-AOV buyers.

CREATE OR REPLACE TABLE mart_marketing_acquisition AS
SELECT
    marketing_channel_at_first_purchase AS marketing_channel,
    loyalty_at_first_purchase           AS loyalty_status,
    COUNT(*)                            AS users_acquired,
    AVG(first_purchase_aov)             AS avg_first_aov,
    SUM(first_purchase_aov)             AS total_first_revenue,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER (
        PARTITION BY marketing_channel_at_first_purchase
    ) AS pct_within_channel
FROM dim_users
WHERE first_purchase_aov IS NOT NULL
GROUP BY marketing_channel_at_first_purchase, loyalty_at_first_purchase
ORDER BY marketing_channel, loyalty_status;