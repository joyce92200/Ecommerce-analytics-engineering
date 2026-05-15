
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select share_of_month_pct
from "dev"."gold"."mart_channel_revenue"
where share_of_month_pct is null



  
  
      
    ) dbt_internal_test