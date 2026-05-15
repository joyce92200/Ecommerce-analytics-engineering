
    
    

select
    product_name as unique_field,
    count(*) as n_records

from "dev"."gold"."mart_product_concentration"
where product_name is not null
group by product_name
having count(*) > 1


