
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        loyalty_status, product_name
    from "dev"."gold"."first_purchase_summary"
    group by loyalty_status, product_name
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test