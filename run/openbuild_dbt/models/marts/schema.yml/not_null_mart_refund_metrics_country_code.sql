
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select country_code
from "dev"."gold"."mart_refund_metrics"
where country_code is null



  
  
      
    ) dbt_internal_test