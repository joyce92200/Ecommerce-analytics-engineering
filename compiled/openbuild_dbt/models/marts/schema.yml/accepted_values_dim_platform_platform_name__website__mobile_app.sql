
    
    

with all_values as (

    select
        platform_name as value_field,
        count(*) as n_records

    from "dev"."gold"."dim_platform"
    group by platform_name

)

select *
from all_values
where value_field not in (
    'website','mobile app'
)


