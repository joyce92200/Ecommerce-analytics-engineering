
    
    

select
    platform_name as unique_field,
    count(*) as n_records

from "dev"."gold"."dim_platform"
where platform_name is not null
group by platform_name
having count(*) > 1


