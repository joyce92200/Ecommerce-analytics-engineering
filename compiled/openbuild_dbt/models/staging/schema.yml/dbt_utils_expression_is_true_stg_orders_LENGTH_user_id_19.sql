



select
    1
from "dev"."silver"."stg_orders"

where not(LENGTH(user_id) <= 19)

