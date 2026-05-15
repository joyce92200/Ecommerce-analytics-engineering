
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select user_order_seq
from "dev"."gold"."fct_orders"
where user_order_seq is null



  
  
      
    ) dbt_internal_test