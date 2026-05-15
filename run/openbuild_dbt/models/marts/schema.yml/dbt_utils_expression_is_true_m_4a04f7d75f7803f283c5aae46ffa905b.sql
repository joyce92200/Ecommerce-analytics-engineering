
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "dev"."gold"."mart_product_concentration"

where not(avg_aov >= 0)


  
  
      
    ) dbt_internal_test