



select
    1
from "dev"."gold"."mart_product_concentration"

where not(pct_of_revenue BETWEEN 0 AND 100)

