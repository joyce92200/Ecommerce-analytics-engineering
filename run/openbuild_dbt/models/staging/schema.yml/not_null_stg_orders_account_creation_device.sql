
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select account_creation_device
from "dev"."silver"."stg_orders"
where account_creation_device is null



  
  
      
    ) dbt_internal_test