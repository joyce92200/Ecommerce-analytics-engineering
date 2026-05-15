
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        platform_type as value_field,
        count(*) as n_records

    from "dev"."gold"."dim_platform"
    group by platform_type

)

select *
from all_values
where value_field not in (
    'web','mobile'
)



  
  
      
    ) dbt_internal_test