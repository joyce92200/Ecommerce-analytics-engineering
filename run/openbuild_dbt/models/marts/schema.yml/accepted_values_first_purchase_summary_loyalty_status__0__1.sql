
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        loyalty_status as value_field,
        count(*) as n_records

    from "dev"."gold"."first_purchase_summary"
    group by loyalty_status

)

select *
from all_values
where value_field not in (
    '0','1'
)



  
  
      
    ) dbt_internal_test