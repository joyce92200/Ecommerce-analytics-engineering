
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "dev"."gold"."mart_marketing_acquisition"

where not(total_first_revenue >= 0)


  
  
      
    ) dbt_internal_test