
    
    

with all_values as (

    select
        account_creation_device as value_field,
        count(*) as n_records

    from "dev"."silver"."stg_orders"
    group by account_creation_device

)

select *
from all_values
where value_field not in (
    'desktop','mobile','unknown','tablet','tv'
)


