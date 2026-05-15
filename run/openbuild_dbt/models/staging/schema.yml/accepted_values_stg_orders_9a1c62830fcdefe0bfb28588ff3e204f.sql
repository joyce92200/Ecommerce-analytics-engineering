
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        marketing_channel as value_field,
        count(*) as n_records

    from "dev"."silver"."stg_orders"
    group by marketing_channel

)

select *
from all_values
where value_field not in (
    'direct','email','affiliate','social media','unknown'
)



  
  
      
    ) dbt_internal_test