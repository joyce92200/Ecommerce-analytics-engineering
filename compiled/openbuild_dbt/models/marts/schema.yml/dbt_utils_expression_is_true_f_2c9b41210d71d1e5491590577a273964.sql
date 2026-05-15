



select
    1
from "dev"."gold"."fct_orders"

where not(months_since_acquisition >= 0)

