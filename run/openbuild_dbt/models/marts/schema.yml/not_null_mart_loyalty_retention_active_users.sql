
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select active_users
from "dev"."gold"."mart_loyalty_retention"
where active_users is null



  
  
      
    ) dbt_internal_test