
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select cohort_size
from "dev"."gold"."mart_loyalty_retention"
where cohort_size is null



  
  
      
    ) dbt_internal_test