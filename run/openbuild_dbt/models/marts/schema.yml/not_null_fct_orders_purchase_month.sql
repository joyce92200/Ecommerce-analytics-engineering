
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select purchase_month
from "dev"."gold"."fct_orders"
where purchase_month is null



  
  
      
    ) dbt_internal_test