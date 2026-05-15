
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select loyalty_status
from "dev"."gold"."fct_orders"
where loyalty_status is null



  
  
      
    ) dbt_internal_test