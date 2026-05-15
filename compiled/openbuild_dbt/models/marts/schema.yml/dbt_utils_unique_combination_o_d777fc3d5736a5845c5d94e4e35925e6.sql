





with validation_errors as (

    select
        marketing_channel, loyalty_status
    from "dev"."gold"."mart_marketing_acquisition"
    group by marketing_channel, loyalty_status
    having count(*) > 1

)

select *
from validation_errors


