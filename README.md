# OpenBuild Analytics Engineering

End-to-end analytics layer for a mid-size electronics retailer.
Medallion architecture · star schema · 28 tested transformations.

---

## The Problem

OpenBuild's leadership needs reliable answers to three questions:
which cohorts come back, where refunds erode margin,
and which platform deserves the next investment dollar.
Raw transactional data — 108K orders across 87K users, four years, 193 countries —
cannot answer them directly. The gap is a modeled, tested data layer.

## The Architecture

Three-layer medallion model. Each layer has a single job.

| Layer | Purpose | Contents |
|---|---|---|
| **Bronze** (raw) | Immutable source of truth | `orders_raw`, `country_lookup_raw` |
| **Silver** (staging) | Type enforcement, deduplication, null handling | `stg_orders`, `stg_country_lookup` |
| **Gold** (marts) | Business semantics, dimensional model | `dim_users`, `dim_product`, `dim_country`, `dim_platform`, `fct_orders`, three analytical marts |

Raw is never edited. Silver is rebuilt on every run. Gold is what stakeholders consume.

![Architecture](data/outputs/architecture_diagram.svg)

## The Model

Star schema. One fact, four dimensions, three derived marts.
Grain: one row per order. The same model answers cohort, refund, and channel questions without rework.

- `dim_users` — one row per user; attributes locked at acquisition time
- `dim_product` — one row per product
- `dim_country` — one row per country with regional rollup
- `dim_platform` — one row per purchase platform with category rollup
- `fct_orders` — one row per order; foreign keys to all four dimensions; cohort enrichment computed once
- `mart_cohort_retention` — monthly retention matrix (cohort × months_since_acquisition)
- `mart_refund_metrics` — refund rate and revenue leak by product × country
- `mart_channel_revenue` — monthly orders and revenue by purchase platform

![Star schema](data/outputs/star_schema.svg)

## The Answers

| Question | Finding |
|---|---|
| **12-month retention by cohort** | Retention is structurally low and stable: ~1% month-1 across all 48 cohorts (Jan 2019 – Dec 2022). Cohort acquisition strategy did not move repurchase behavior — product mix is the lever, not marketing. |
| **Refund rate by product × country** | Laptops refund 2-3× the company average. MacBook Air × US is the single largest dollar leak ($365K refunded). ThinkPad × CA refunds at 21.3% vs. 12.9% in the US — same product, very different market behavior worth investigating. |
| **Revenue split: website vs. mobile app** | Website is 96.8% of lifetime revenue. Mobile generates 17% of orders but only 3% of revenue — structurally a low-AOV channel skewed toward accessories. Trend essentially flat (2.95% → 3.93% over 48 months). Mobile investment thesis must shift toward AOV uplift, not order volume. |

### Retention pattern

![Cohort retention heatmap](data/outputs/cohort_retention_heatmap.png)

*Cohort × month-since-acquisition. Color intensity = % of cohort active. Read vertically: month-1 retention is structurally flat at ~1% across all 48 cohorts.*

### Refund concentration

![Refund top segments](data/outputs/refund_top_segments.png)

*Top 10 product × country refund rates (segments with ≥100 orders). Bar length = rate. Bar color = absolute dollar leak. Laptops dominate; MacBook Air × US combines high rate with high volume.*

### Channel mix over time

![Channel revenue trend](data/outputs/channel_revenue_trend.png)

*Monthly net revenue, website (blue) vs. mobile app (amber). The orange band's flat width across 4 years is the "structurally low-AOV" finding visualized.*

## Data Quality

Tests run on every model build. **28 assertions** across schema, uniqueness, referential integrity, domain values, and derived-column invariants. All passing.

| Test type | Examples | Coverage |
|---|---|---|
| `not_null` | `dim_users.user_id`, `fct_orders.order_id`, `purchase_ts` | Schema integrity |
| `unique` | All four dimension primary keys; `fct_orders.order_id` | Primary key contracts |
| `relationships` | All four FKs from `fct_orders` to dimension tables | Referential integrity |
| `accepted_values` | `purchase_platform ∈ {website, mobile app}` | Domain constraints |
| `range` | `retention_pct ∈ [0, 100]` | Bounds checking |
| `invariants` | `refunded_revenue + net_revenue = gross_revenue`; monthly platform shares sum to 100 | Derivation correctness |

### Quality Decisions

- **3 orders (0.003%)** with unparseable purchase timestamps excluded from cohort assignment
- **2 columns** (`MARKETING_CHANNEL_cleaned`, `ACCOUNT_CREATION_METHOD_cleaned`) entirely null; excluded from model
- **`country_lookup_raw` had a duplicate primary key** for `US` (rows with regions `'x'` and `'North America'`); resolved at silver layer with deterministic deduplication, mapped to canonical `AMER` region
- **18 orders use `EU` or `AP` as country codes** (region-bloc identifiers entered as country codes — a contract violation in the source); preserved as `Unclassified` rows in `dim_country` to maintain referential integrity without losing the orders
- **26 source countries had NULL or junk regions** (`'x'`, NULL, etc.); mapped to `Unclassified` rather than dropped
- **4 orders roll up under NULL `country_code`** (missing geolocation); retained as a distinct segment so refund leakage from unknown-country orders remains visible
- **Raw `_RAW` columns retained** in bronze for audit lineage; gold uses cleaned versions only
- **Cohorts after Dec 2021** are right-censored; 12-month retention reported only for fully observable cohorts

## The Stack

**Built:** DuckDB · pandas · Jupyter · SQL · Git
**Roadmap:** dbt Core migration · GitHub Actions CI · BI dashboard layer · SCD Type 2 on `dim_users` · forecasting module on platform revenue

## Repository

```text
.
├── data/
│   ├── raw/                          # Bronze · immutable source
│   ├── processed/                    # Silver · staging outputs
│   └── outputs/                      # Final analytical artifacts
│       ├── architecture_diagram.svg
│       ├── star_schema.svg
│       └── cohort_retention_heatmap.png
├── notebooks/
│   └── 01_cohort_exploration.ipynb
├── sql/
│   ├── staging/
│   │   ├── stg_orders.sql
│   │   └── stg_country_lookup.sql
│   └── marts/
│       ├── dim_users.sql
│       ├── dim_product.sql
│       ├── dim_country.sql
│       ├── dim_platform.sql
│       ├── fct_orders.sql
│       ├── mart_cohort_retention.sql
│       ├── mart_refund_metrics.sql
│       └── mart_channel_revenue.sql
├── tests/
│   └── test_models.sql               # 28 data-quality assertions
└── docs/                             # Methodology and decision logs
```

## What's Next

dbt Core migration · GitHub Actions CI for automated test runs · SCD Type 2 on `dim_users` · BI dashboard layer · forecasting module on platform revenue

---

*Code in `/sql` and `/notebooks`. Data quality decisions in this README; deeper methodology notes in `/docs`.*