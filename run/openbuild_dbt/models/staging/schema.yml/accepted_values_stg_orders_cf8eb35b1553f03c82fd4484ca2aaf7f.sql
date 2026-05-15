
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        purchase_platform as value_field,
        count(*) as n_records

    from "dev"."silver"."stg_orders"
    group by purchase_platform

)

select *
from all_values
where value_field not in (
    'website','mobile app'
)



  
  
      
    ) dbt_internal_test