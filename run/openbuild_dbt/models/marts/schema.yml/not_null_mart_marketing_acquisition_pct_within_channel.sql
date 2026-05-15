
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select pct_within_channel
from "dev"."gold"."mart_marketing_acquisition"
where pct_within_channel is null



  
  
      
    ) dbt_internal_test