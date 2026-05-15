
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select months_since_acquisition
from "dev"."gold"."mart_loyalty_retention"
where months_since_acquisition is null



  
  
      
    ) dbt_internal_test