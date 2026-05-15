
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select purchase_ts
from "dev"."silver"."stg_orders"
where purchase_ts is null



  
  
      
    ) dbt_internal_test