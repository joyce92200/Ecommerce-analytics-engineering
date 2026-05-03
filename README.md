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
| **Revenue by category (QoQ)** | Audio revenue +18% (promotion-driven)<br><br>**High:** Q4 seasonality<br>**High:** Discounting increased conversion/AOV<br>**Medium:** Promotion placement / bundling |
| **Return rate by segment** | New customers: 2.3× higher return rate vs repeat<br><br>**High:** Expectation mismatch<br>**High:** Low product familiarity<br>**Medium:** Promotion-driven, lower-intent purchases |
| **90-day repeat rate by channel** | Organic: 31%<br>Paid social: 9%<br><br>**High:** Intent gap (organic vs discovery)<br>**High:** Broader targeting (lower qualification)<br>**Medium:** Creative / offer misalignment |
| **12-month retention by cohort** | ~1% month-1 retention, flat across 48 cohorts (Jan 2019–Dec 2022)<br>No impact from acquisition changes<br><br>**High:** Low natural repeat frequency (product lifecycle)<br>**High:** Limited cross-sell opportunities<br>**Medium:** One-off purchase-heavy catalog |
| **Refund rate by product × country** | Laptops: 2–3× above average<br>MacBook Air (US): $365K refunded<br>ThinkPad (CA): 21.3% vs 12.9% (US)<br><br>**High:** High price → higher return risk<br>**High:** Spec / expectation mismatch<br>**Medium:** Market-specific return behavior<br>**Medium:** Localization (pricing, positioning, support) |
| **Revenue split: website vs. mobile app** | Website: 96.8% revenue<br>Mobile: 17% orders / 3% revenue<br>Stable trend (2.95% → 3.93%)<br><br>**High:** Mobile skew to low-AOV purchases<br>**High:** Product mix (accessories-heavy)<br>**Medium:** Mobile UX limits high-value checkout<br>**Low–Medium:** Desktop preference for large purchases |

### Retention heatmap

![Cohort retention heatmap](data/outputs/cohort_retention_heatmap.png)

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
