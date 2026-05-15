



select
    1
from "dev"."gold"."mart_cohort_retention"

where not(months_since_acquisition >= 0)

