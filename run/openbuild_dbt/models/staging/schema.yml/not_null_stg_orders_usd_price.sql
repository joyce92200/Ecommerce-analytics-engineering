
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select usd_price
from "dev"."silver"."stg_orders"
where usd_price is null



  
  
      
    ) dbt_internal_test