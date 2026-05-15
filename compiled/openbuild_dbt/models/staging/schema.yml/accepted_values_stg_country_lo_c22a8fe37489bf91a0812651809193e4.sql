
    
    

with all_values as (

    select
        region as value_field,
        count(*) as n_records

    from "dev"."silver"."stg_country_lookup"
    group by region

)

select *
from all_values
where value_field not in (
    'AMER','EMEA','APAC','LATAM','Unclassified'
)


