
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select product_name
from "dev"."gold"."mart_refund_metrics"
where product_name is null



  
  
      
    ) dbt_internal_test