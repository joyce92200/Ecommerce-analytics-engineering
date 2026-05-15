
    
    

with all_values as (

    select
        product_name as value_field,
        count(*) as n_records

    from "dev"."gold"."dim_product"
    group by product_name

)

select *
from all_values
where value_field not in (
    'Apple Airpods Headphones','27in 4K gaming monitor','Samsung Charging Cable Pack','Samsung Webcam','Macbook Air Laptop','ThinkPad Laptop','Apple iPhone','bose soundsport headphones'
)


