
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select device_at_first_purchase
from "dev"."gold"."dim_users"
where device_at_first_purchase is null



  
  
      
    ) dbt_internal_test