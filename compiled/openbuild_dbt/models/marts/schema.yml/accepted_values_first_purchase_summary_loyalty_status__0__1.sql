
    
    

with all_values as (

    select
        loyalty_status as value_field,
        count(*) as n_records

    from "dev"."gold"."first_purchase_summary"
    group by loyalty_status

)

select *
from all_values
where value_field not in (
    '0','1'
)


