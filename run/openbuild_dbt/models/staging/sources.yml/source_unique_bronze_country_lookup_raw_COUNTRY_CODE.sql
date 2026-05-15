
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    COUNTRY_CODE as unique_field,
    count(*) as n_records

from "dev"."bronze"."country_lookup_raw"
where COUNTRY_CODE is not null
group by COUNTRY_CODE
having count(*) > 1



  
  
      
    ) dbt_internal_test