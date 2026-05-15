
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select first_orders
from "dev"."gold"."first_purchase_summary"
where first_orders is null



  
  
      
    ) dbt_internal_test