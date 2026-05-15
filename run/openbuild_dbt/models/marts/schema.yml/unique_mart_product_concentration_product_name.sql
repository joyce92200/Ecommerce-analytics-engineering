
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    product_name as unique_field,
    count(*) as n_records

from "dev"."gold"."mart_product_concentration"
where product_name is not null
group by product_name
having count(*) > 1



  
  
      
    ) dbt_internal_test