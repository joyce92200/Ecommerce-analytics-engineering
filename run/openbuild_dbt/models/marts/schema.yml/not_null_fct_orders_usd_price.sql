
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select usd_price
from "dev"."gold"."fct_orders"
where usd_price is null



  
  
      
    ) dbt_internal_test