
    
    

with child as (
    select purchase_platform as from_field
    from "dev"."gold"."fct_orders"
    where purchase_platform is not null
),

parent as (
    select platform_name as to_field
    from "dev"."gold"."dim_platform"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


