
    
    

with all_values as (

    select
        purchase_platform as value_field,
        count(*) as n_records

    from "dev"."gold"."mart_channel_revenue"
    group by purchase_platform

)

select *
from all_values
where value_field not in (
    'website','mobile app'
)


