



select
    1
from "dev"."gold"."mart_channel_revenue"

where not(gross_revenue_usd >= 0)

