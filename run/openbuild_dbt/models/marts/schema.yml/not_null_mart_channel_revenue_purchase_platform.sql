
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select purchase_platform
from "dev"."gold"."mart_channel_revenue"
where purchase_platform is null



  
  
      
    ) dbt_internal_test