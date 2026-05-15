
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select country_code
from "dev"."gold"."fct_orders"
where country_code is null



  
  
      
    ) dbt_internal_test