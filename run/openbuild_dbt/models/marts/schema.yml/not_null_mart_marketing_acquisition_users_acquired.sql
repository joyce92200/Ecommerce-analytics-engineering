
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select users_acquired
from "dev"."gold"."mart_marketing_acquisition"
where users_acquired is null



  
  
      
    ) dbt_internal_test