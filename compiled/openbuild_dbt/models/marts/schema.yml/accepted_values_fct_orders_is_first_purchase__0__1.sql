
    
    

with all_values as (

    select
        is_first_purchase as value_field,
        count(*) as n_records

    from "dev"."gold"."fct_orders"
    group by is_first_purchase

)

select *
from all_values
where value_field not in (
    '0','1'
)


