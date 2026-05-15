



select
    1
from "dev"."gold"."mart_refund_metrics"

where not(refund_rate_pct BETWEEN 0 AND 100)

