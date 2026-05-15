
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "dev"."gold"."fct_orders"

where not(months_since_acquisition >= 0)


  
  
      
    ) dbt_internal_test