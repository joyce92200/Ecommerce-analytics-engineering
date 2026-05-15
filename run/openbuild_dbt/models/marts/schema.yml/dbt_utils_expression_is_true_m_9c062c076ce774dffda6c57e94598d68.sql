
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "dev"."gold"."mart_product_concentration"

where not(cumulative_pct_of_revenue BETWEEN 0 AND 100.01)


  
  
      
    ) dbt_internal_test