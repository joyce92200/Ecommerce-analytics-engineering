



select
    1
from "dev"."gold"."mart_channel_revenue"

where not(share_of_month_pct BETWEEN 0 AND 100)

