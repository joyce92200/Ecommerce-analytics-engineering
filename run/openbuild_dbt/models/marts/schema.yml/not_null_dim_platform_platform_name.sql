
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select platform_name
from "dev"."gold"."dim_platform"
where platform_name is null



  
  
      
    ) dbt_internal_test