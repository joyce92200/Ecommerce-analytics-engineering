



select
    1
from "dev"."gold"."mart_marketing_acquisition"

where not(pct_within_channel BETWEEN 0 AND 100)

