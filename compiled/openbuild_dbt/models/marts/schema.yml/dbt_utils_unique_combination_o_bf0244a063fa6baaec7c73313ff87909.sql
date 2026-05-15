





with validation_errors as (

    select
        product_name, country_code
    from "dev"."gold"."mart_refund_metrics"
    group by product_name, country_code
    having count(*) > 1

)

select *
from validation_errors


