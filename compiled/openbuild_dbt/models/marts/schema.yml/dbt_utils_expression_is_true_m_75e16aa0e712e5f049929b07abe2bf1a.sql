



select
    1
from "dev"."gold"."mart_refund_metrics"

where not(gross_revenue_usd >= 0)

