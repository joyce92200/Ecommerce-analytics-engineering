
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "dev"."gold"."mart_channel_revenue"

where not(orders > 0)


  
  
      
    ) dbt_internal_test