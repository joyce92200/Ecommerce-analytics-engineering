
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select loyalty_status
from "dev"."gold"."mart_marketing_acquisition"
where loyalty_status is null



  
  
      
    ) dbt_internal_test