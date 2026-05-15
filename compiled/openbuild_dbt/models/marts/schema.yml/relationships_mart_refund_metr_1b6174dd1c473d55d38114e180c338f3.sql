
    
    

with child as (
    select product_name as from_field
    from "dev"."gold"."mart_refund_metrics"
    where product_name is not null
),

parent as (
    select product_name as to_field
    from "dev"."gold"."dim_product"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


