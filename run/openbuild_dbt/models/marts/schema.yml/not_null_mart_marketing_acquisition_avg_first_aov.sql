
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select avg_first_aov
from "dev"."gold"."mart_marketing_acquisition"
where avg_first_aov is null



  
  
      
    ) dbt_internal_test