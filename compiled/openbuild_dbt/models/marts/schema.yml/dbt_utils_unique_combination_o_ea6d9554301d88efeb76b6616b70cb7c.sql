





with validation_errors as (

    select
        cohort_month, loyalty_status, months_since_acquisition
    from "dev"."gold"."mart_loyalty_retention"
    group by cohort_month, loyalty_status, months_since_acquisition
    having count(*) > 1

)

select *
from validation_errors


