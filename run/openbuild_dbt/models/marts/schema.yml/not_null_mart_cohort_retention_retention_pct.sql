
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select retention_pct
from "dev"."gold"."mart_cohort_retention"
where retention_pct is null



  
  
      
    ) dbt_internal_test