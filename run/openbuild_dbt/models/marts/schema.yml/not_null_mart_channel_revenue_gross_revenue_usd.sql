
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select gross_revenue_usd
from "dev"."gold"."mart_channel_revenue"
where gross_revenue_usd is null



  
  
      
    ) dbt_internal_test