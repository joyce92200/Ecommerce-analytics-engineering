





with validation_errors as (

    select
        purchase_month, purchase_platform
    from "dev"."gold"."mart_channel_revenue"
    group by purchase_month, purchase_platform
    having count(*) > 1

)

select *
from validation_errors


