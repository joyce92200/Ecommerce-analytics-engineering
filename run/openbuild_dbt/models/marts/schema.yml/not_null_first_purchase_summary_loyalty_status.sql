
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select loyalty_status
from "dev"."gold"."first_purchase_summary"
where loyalty_status is null



  
  
      
    ) dbt_internal_test