
    
    

with all_values as (

    select
        marketing_channel_at_first_purchase as value_field,
        count(*) as n_records

    from "dev"."gold"."dim_users"
    group by marketing_channel_at_first_purchase

)

select *
from all_values
where value_field not in (
    'direct','email','affiliate','social media','unknown'
)


