
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select first_purchase_ts
from "dev"."gold"."dim_users"
where first_purchase_ts is null



  
  
      
    ) dbt_internal_test