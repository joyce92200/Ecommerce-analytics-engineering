
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_first_purchase
from "dev"."gold"."fct_orders"
where is_first_purchase is null



  
  
      
    ) dbt_internal_test