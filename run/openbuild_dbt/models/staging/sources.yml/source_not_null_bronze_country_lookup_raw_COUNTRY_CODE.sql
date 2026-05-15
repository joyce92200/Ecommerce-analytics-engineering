
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select COUNTRY_CODE
from "dev"."bronze"."country_lookup_raw"
where COUNTRY_CODE is null



  
  
      
    ) dbt_internal_test