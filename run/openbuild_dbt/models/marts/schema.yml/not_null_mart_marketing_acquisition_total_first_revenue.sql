
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select total_first_revenue
from "dev"."gold"."mart_marketing_acquisition"
where total_first_revenue is null



  
  
      
    ) dbt_internal_test