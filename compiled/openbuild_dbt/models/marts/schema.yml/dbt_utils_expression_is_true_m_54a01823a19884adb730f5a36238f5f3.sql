



select
    1
from "dev"."gold"."mart_refund_metrics"

where not(net_revenue_usd >= 0)

