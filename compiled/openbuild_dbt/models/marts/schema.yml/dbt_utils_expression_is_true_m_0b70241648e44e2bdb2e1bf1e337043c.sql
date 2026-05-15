



select
    1
from "dev"."gold"."mart_refund_metrics"

where not(refunded_revenue_usd >= 0)

