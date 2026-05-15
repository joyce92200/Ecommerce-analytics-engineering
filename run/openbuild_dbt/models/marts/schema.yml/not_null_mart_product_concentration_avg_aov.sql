
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select avg_aov
from "dev"."gold"."mart_product_concentration"
where avg_aov is null



  
  
      
    ) dbt_internal_test