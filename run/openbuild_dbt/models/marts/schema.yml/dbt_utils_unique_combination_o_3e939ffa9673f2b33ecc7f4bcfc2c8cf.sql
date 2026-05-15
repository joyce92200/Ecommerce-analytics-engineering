
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        purchase_month, purchase_platform
    from "dev"."gold"."mart_channel_revenue"
    group by purchase_month, purchase_platform
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test