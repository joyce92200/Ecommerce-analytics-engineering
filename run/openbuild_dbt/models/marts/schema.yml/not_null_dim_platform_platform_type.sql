
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select platform_type
from "dev"."gold"."dim_platform"
where platform_type is null



  
  
      
    ) dbt_internal_test