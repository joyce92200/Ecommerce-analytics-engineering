



select
    1
from "dev"."gold"."mart_cohort_retention"

where not(retention_pct BETWEEN 0 AND 100)

