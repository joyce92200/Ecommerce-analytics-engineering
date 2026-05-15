
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select net_revenue
from "dev"."gold"."mart_product_concentration"
where net_revenue is null



  
  
      
    ) dbt_internal_test