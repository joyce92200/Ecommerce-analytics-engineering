
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "dev"."gold"."mart_cohort_retention"

where not(retention_pct BETWEEN 0 AND 100)


  
  
      
    ) dbt_internal_test