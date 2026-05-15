
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select pct_of_revenue
from "dev"."gold"."mart_product_concentration"
where pct_of_revenue is null



  
  
      
    ) dbt_internal_test