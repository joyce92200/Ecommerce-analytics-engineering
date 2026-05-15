
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select refund_rate_pct
from "dev"."gold"."mart_refund_metrics"
where refund_rate_pct is null



  
  
      
    ) dbt_internal_test