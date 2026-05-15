
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_refunded
from "dev"."silver"."stg_orders"
where is_refunded is null



  
  
      
    ) dbt_internal_test