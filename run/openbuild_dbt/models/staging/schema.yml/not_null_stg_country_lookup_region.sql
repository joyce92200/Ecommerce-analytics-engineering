
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select region
from "dev"."silver"."stg_country_lookup"
where region is null



  
  
      
    ) dbt_internal_test