# OpenBuild Analytics Engineering

End-to-end analytics engineering project for a mid-size global electronics retailer.

Built a tested analytics layer using medallion architecture, dimensional modeling, SQL transformation pipelines, and business-facing analytical marts to support executive decision-making across retention, refunds, and channel strategy.

[**🚀 Live dashboard**](https://openbuild-analytics.streamlit.app) · [**📄 Executive 1-pager (PDF)**](docs/openbuild_findings_one_pager.pdf) — methodology in Appendix A1, A1b, A2, A3

---

## Numbers at a glance

| | |
|---|---|
| **Scope** | 108,124 orders · 87,625 users · 193 countries · Jan 2019 – Dec 2022 |
| **Models** | 2 silver · 4 dimensions · 1 fact · 4 analytical marts |
| **Tests** | 32 assertions across schema, uniqueness, referential integrity, and derived-column invariants — all passing |
| **Findings** | Retention 0.8%–1.4% month-1 across 48 cohorts (loyalty members retain 3.6× worse) · refund baseline 4.97% (laptops 12-21%) · website 96.8% of revenue |

---

## Executive Summary

OpenBuild operates across 193 countries with more than 108K orders collected between 2019–2022. Leadership lacked a reliable analytical layer capable of answering three operational questions consistently:

- Which customer cohorts return?
- Which refund segments erode margin?
- Which sales channels justify future investment?

To address this, I designed and implemented:
- a 3-layer medallion architecture
- a star-schema dimensional model
- 32 automated data-quality tests
- reproducible SQL and notebook workflows

The resulting analytics layer produced three primary findings:

- Retention weakness was structural across all cohorts and driven primarily by product mix rather than acquisition timing
- Refund exposure was concentrated in high-AOV laptop categories, particularly specific product-country combinations
- Website remained the dominant revenue channel, while mobile functioned primarily as a low-AOV support and onboarding channel

The project transformed raw transactional data into a governed analytical layer suitable for operational and executive reporting.

---

## Dataset Overview

| Metric | Value |
|---|---|
| Orders | 108,124 |
| Users | 87,625 |
| Countries | 193 |
| Time range | Jan 2019 – Dec 2022 |
| Fact tables | 1 |
| Dimension tables | 4 |
| Analytical marts | 4 |
| Data-quality assertions | 32 passing tests |

---

## The Architecture

Three-layer medallion model. Each layer has a single job.

| Layer | Purpose | Contents |
|---|---|---|
| **Bronze** (raw) | Immutable source of truth | `orders_raw`, `country_lookup_raw` |
| **Silver** (staging) | Type enforcement, deduplication, null handling | `stg_orders`, `stg_country_lookup` |
| **Gold** (marts) | Business semantics, dimensional model | `dim_users`, `dim_product`, `dim_country`, `dim_platform`, `fct_orders`, four analytical marts |

Raw is never edited. Silver is rebuilt on every run. Gold is what stakeholders consume.

![Architecture](data/outputs/architecture_diagram.svg)

---

## Dimensional Modeling - Star Schema

### Fact Table

| Table | Grain |
|---|---|
| `fct_orders` | One row per order |

### Dimension Tables

| Dimension | Description |
|---|---|
| `dim_users` | Customer acquisition attributes |
| `dim_product` | Product attributes |
| `dim_country` | Country and regional hierarchy |
| `dim_platform` | Purchase-channel hierarchy |

The same model supports:
- retention analysis
- refund analysis
- platform analysis
- loyalty segmentation

without duplicating transformation logic.

![Star schema](data/outputs/star_schema.svg)

### Validations

The findings backed by the SQL marts above. Each cause is labeled `tested` (validated in this analysis), `partially tested` (directional evidence), or `hypothesis` (plausible but requires further data).

---

## Business Findings

### Finding 1 — Loyalty program cohorts retain materially worse than non-loyalty cohorts

**Result.** Month-1 retention remained structurally low across all 48 acquisition cohorts, ranging between **0.8%–1.4%**. Loyalty cohorts retained materially worse than non-loyalty cohorts, with the gap widening after 2020 program expansion.

Loyalty acquisition skewed heavily toward one-time-purchase products, particularly AirPods, while replenishable categories remained underrepresented.

**Implication.** Cohort timing alone does not explain retention outcomes. The evidence suggests product mix is a stronger driver of repeat-purchase behavior than acquisition period effects.

| Cause | Weight | Status |
|---|---|---|
| Durable-goods catalog suppresses repurchase frequency | High | `tested` |
| Loyalty acquisition concentrated in one-time-purchase categories | High | `tested` |
| Limited replenishable-product penetration | High | `tested` |
| Checkout cross-sell limitations | Medium | `hypothesis` |

*Sources: `mart_cohort_retention`, `mart_loyalty_retention`, `dim_users`, `fct_orders`. Methodology: Appendix A1, A1b.*

![Cohort retention heatmap](data/outputs/cohort_retention_heatmap.png)
*Cohort × month-since-acquisition. Color intensity = % of cohort active. Read vertically: month-1 retention is structurally flat at ~1% across all 48 cohorts.*

![Loyalty retention analysis](data/outputs/loyalty_retention_analysis.png)
*Left: averaged retention curves — loyalty trails 3.6× at month 1, converges by month 9. Right: month-1 retention by cohort year — the gap was small in 2019 and emerged sharply in 2020 alongside aggressive program scaling.*

---

### Finding 2 — Laptop categories dominate refund leakage

**Result.**
- Overall refund baseline: **4.97%**
- Worst segment: **ThinkPad × Canada = 21.3%**
- Largest dollar leakage: **MacBook Air × US = $365K refunded revenue**

Every top-10 refund segment belonged to laptop categories.

**Implication.** Refund-reduction initiatives should prioritize high-AOV laptop segments before lower-value accessory categories.

| Cause | Weight | Status |
|---|---|---|
| High-AOV products carry greater refund exposure | High | `tested` |
| Product-specification mismatch | High | `partially tested` |
| Country-level fulfillment variation | Medium | `partially tested` |
| Localization and positioning differences | Medium | `hypothesis` |

*Source: `mart_refund_metrics`, `fct_orders`, `dim_country`. Methodology: Appendix A2.*

![Refund top segments](data/outputs/refund_top_segments.png)
*Top 10 product × country refund rates (segments with ≥100 orders). Bar length = rate. Bar color = absolute dollar leak. Laptops dominate; MacBook Air × US combines high rate with high volume.*

---

### Finding 3 — Mobile is structurally a low-AOV channel

**Result.**
- Website generated **96.8%** of total revenue
- Mobile generated **17.1%** of orders but only **3.2%** of revenue
- Mobile AOV was approximately **5× lower** than website AOV

The mobile share improved modestly over four years but remained operationally small relative to revenue contribution.

**Implication.** Mobile investment strategy should prioritize AOV improvement rather than order-volume growth.

| Cause | Weight | Status |
|---|---|---|
| Mobile purchases skew toward accessories | High | `tested` |
| Catalog structure favors desktop purchasing | High | `tested` |
| Mobile checkout friction for high-value purchases | Medium | `hypothesis` |
| Desktop preference for considered purchases | Medium | `hypothesis` |
*Source: `mart_channel_revenue`, `fct_orders`, `dim_platform`. Methodology: Appendix A3.*

![Channel revenue trend](data/outputs/channel_revenue_trend.png)
*Monthly net revenue, website (blue) vs. mobile app (amber). The orange band's flat width across 4 years is the "structurally low-AOV" finding visualized.*

---

### Finding 4 — Mobile acquisition does not translate into mobile purchasing

**Result.** Account-creation method only partially predicts purchase behavior. Desktop-created users purchase through the website **89.1%** of the time. Mobile-created users remain split between channels, with only **46.2%** purchasing through the mobile app and **53.8%** still purchasing through the website.

| Account creation method | Website share | Mobile-app share |
|---|---:|---:|
| Desktop | 89.1% | 10.9% |
| Mobile | 53.8% | 46.2% |
| Tablet | 78.0% | 22.0% |

The mobile-app share improved after 2020 but never became dominant. Even mobile-origin users continued migrating to web checkout.

**Implication.** Acquisition channel is weaker than transaction behavior. The mobile app appears effective for onboarding and browsing, but high-value purchases continue to consolidate on web. This reinforces the earlier finding that mobile functions as a structurally low-AOV channel rather than a primary revenue driver.

| Cause | Weight | Status |
|---|---|---|
| High-AOV purchases migrate toward desktop checkout | High | `partially tested` |
| Mobile users skew toward lower-value accessory purchases | High | `tested` |
| Product discovery occurs on mobile, conversion on web | Medium | `hypothesis` |
| Mobile checkout friction for considered purchases | Medium | `hypothesis` |

---

## Recommendations

Specific actions, organized by finding. Each is grounded in a tested or partially-tested cause from above.

### From Finding 1 — Retention & Loyalty

**1. Restructure loyalty signup mechanics to favor replenishable categories.** Today, loyalty disproportionately recruits Airpods buyers (58.3%). Replace generic signup offers with category-specific ones — *e.g.*, "Join loyalty, get a free Charging Cable Pack." This addresses the recruitment-mix root cause directly without changing the program's points or discount structure.

**2. Run a 60-day test withholding loyalty enrollment from one-and-done categories.** Pause auto-enroll on Airpods purchases for two months and measure month-1 retention of the affected cohort. If retention rises toward the 1.63% non-loyalty baseline, the recruitment-mix hypothesis is confirmed; the program then needs a redesign, not just amplification.

**3. Stop using "loyalty members AOV" as a program success metric.** AOV at first purchase is equal across segments ($239 vs. $257) — the program isn't driving spend, it's selecting buyers. Replace this KPI with **month-12 retention rate by signup cohort**, which directly measures whether members come back.

### From Finding 2 — Refunds

**1. Investigate ThinkPad Canada specifically.** 21.3% refund rate vs. 12.9% in the US for the same product is an 8.4 pp gap that's almost certainly operational, not product-quality. Audit fulfillment partners, returns policy, and localization (pricing, language, expected specs) for the Canadian market.

**2. Prioritize laptop refund reduction by dollar leak, not rate.** MacBook Air × US has a moderate 12.4% rate but accounts for $365K refunded — more than any other segment. A 2 pp reduction would retain approximately $58K quarterly revenue (~$232K annualized), making this one of the highest-leverage operational interventions identified in the analysis.

**3. Add a fulfillment-SLA × refund correlation analysis to the next iteration.** If laptops with longer shipping times have higher refund rates, the lever shifts from product-listing accuracy to operations. This requires shipment-tracking data not in the current dataset.

### From Finding 3 — Channel Mix

**1. Stop measuring mobile success in order volume.** With AOV ~5× lower than web, doubling mobile orders only adds ~3 pp to total revenue. Reframe mobile KPIs around AOV growth and high-value category attach rate.

**2. Investigate why mobile users skew toward accessories.** Hypothesis: high-AOV product pages (laptops, monitors) are not mobile-optimized. Run a checkout-funnel analysis comparing mobile vs. web conversion at each stage, segmented by product category.

**3. Defer mobile growth investments until AOV mix shifts.** The 4-year mobile share trend (2.95% → 3.93%) is real but trivially small. Before allocating engineering resources to mobile UX, test whether the AOV gap can be closed at all.

### From Finding 4 - Account Creation to Purchase 
**1. Measure mobile performance using value-based metrics rather than acquisition metrics.**  
Mobile account creation does not reliably translate into mobile purchasing behavior. Performance tracking should prioritize mobile AOV, high-value conversion rate, and revenue contribution rather than app signups or order volume alone.

**2. Investigate cross-device checkout migration.**  
More than half of mobile-created users ultimately purchase through the website. The next analytical step should map user journeys between account creation and checkout to identify where high-value purchases transition from mobile to desktop.

**3. Prioritize mobile optimization selectively by product category.**  
The evidence suggests customers are comfortable using mobile for lower-value accessory purchases but shift toward web for considered purchases. Product categories with high desktop migration should be prioritized for mobile UX and checkout testing.

**4. Reframe the role of the mobile app within the commercial ecosystem.**  
Current behavior indicates the mobile app functions more effectively as a discovery and onboarding channel than as a primary revenue channel. Investment decisions should reflect this operational role until mobile conversion quality materially improves.

---

## Data Quality

### Test Coverage

A total of **32 assertions** validate the analytical layer.

| Test Type | Validation |
|---|---|
| `not_null` | Required business keys |
| `unique` | Primary-key integrity |
| `relationships` | Foreign-key consistency |
| `accepted_values` | Domain validation |
| `range` | Numerical bounds |
| `invariants` | Derived-metric correctness |

### Examples
- `refund_revenue + net_revenue = gross_revenue`
- Cohort month-0 retention must equal 100%
- Platform shares must sum to 100%

---

## Key Data Quality Decisions

| Issue | Resolution |
|---|---|
| Duplicate `US` region mappings | Deterministic silver-layer deduplication |
| Invalid country codes (`EU`, `AP`) | Preserved as `Unclassified` |
| Null/junk regions | Standardized to `Unclassified` |
| Invalid timestamps | Excluded from cohort assignment only |
| Missing geolocation rows | Retained for analytical completeness |

---

## Technical Stack

### Core Stack
- SQL
- DuckDB
- pandas
- Jupyter
- Git

### Planned Enhancements
- dbt Core migration
- GitHub Actions CI/CD
- BI dashboard layer
- Slowly Changing Dimensions (SCD Type 2)
- Forecasting module

---

## Reproducibility

```bash
git clone https://github.com/joyce92200/ecommerce-analytics-engineering.git

cd ecommerce-analytics-engineering

python -m venv .venv
source .venv/Scripts/activate

pip install -r requirements.txt

jupyter notebook notebooks/01_cohort_exploration.ipynb
```

Run all notebook cells from top to bottom.

Expected result:
- 32/32 data-quality tests passing
- Analytical outputs matching documented findings

---

## Repository Structure

```text
.
├── data/
│   ├── raw/
│   ├── processed/
│   └── outputs/
├── docs/
├── notebooks/
├── sql/
│   ├── staging/
│   └── marts/
└── tests/
```

---

## What This Project Demonstrates

This project demonstrates:
- dimensional modeling
- analytics engineering workflows
- SQL transformation design
- cohort and retention analysis
- data-quality governance
- reproducible analytics workflows
- executive-level analytical communication

---

## Lessons Learned

The strongest findings emerged from rigorous testing and anti-confounding methodology rather than visualization alone.

Two examples:
- detecting duplicate country mappings through integrity testing
- preventing reverse-causality bias by snapshotting loyalty status at acquisition time instead of current state

This reinforced a core analytics-engineering principle:

> Reliable business conclusions depend on reliable data contracts.

---

## Future Improvements

With additional operational datasets, the next iteration would include:
- fulfillment SLA vs refund-rate analysis
- checkout-funnel analysis by device type
- loyalty signup-source attribution
- customer lifetime value modeling
- forecasting and anomaly detection

---

*Code in `/sql` and `/notebooks`. Data quality decisions in this README; full methodology in [`docs/openbuild_findings_one_pager.pdf`](docs/openbuild_findings_one_pager.pdf).*
