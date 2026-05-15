
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select marketing_channel
from "dev"."silver"."stg_orders"
where marketing_channel is null



  
  
      
    ) dbt_internal_test