
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select first_purchase_aov
from "dev"."gold"."dim_users"
where first_purchase_aov is null



  
  
      
    ) dbt_internal_test