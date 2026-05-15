
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        cohort_month, months_since_acquisition
    from "dev"."gold"."mart_cohort_retention"
    group by cohort_month, months_since_acquisition
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test