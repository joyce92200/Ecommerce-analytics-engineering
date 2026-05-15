
    
    

with all_values as (

    select
        device_at_first_purchase as value_field,
        count(*) as n_records

    from "dev"."gold"."dim_users"
    group by device_at_first_purchase

)

select *
from all_values
where value_field not in (
    'desktop','mobile','unknown','tablet','tv'
)


