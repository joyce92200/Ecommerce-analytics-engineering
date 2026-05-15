
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "dev"."silver"."stg_orders"

where not(LENGTH(user_id) <= 19)


  
  
      
    ) dbt_internal_test