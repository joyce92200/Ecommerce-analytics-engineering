# OpenBuild Analytics Engineering

End-to-end analytics layer for a mid-size electronics retailer.
From raw orders to executive dashboard.

---

## The Problem

OpenBuild's leadership needs reliable answers to 3 questions:
which products drive revenue, which customers return, 
and which channels acquire profitable buyers.

Raw transactional data cannot answer these directly.

## The Approach

Three-layer model (bronze → silver → gold).
Bronze preserves source data. Silver enforces quality. 
Gold serves business semantics through a star schema.

[architecture diagram]

## The Model

2 facts, 3 dimensions. Grain: 1 row per order line.
Designed so the same model answers questions at product, 
order, and customer level without rework.

[star schema diagram]

## The Answers

| Question | Finding |
|---|---|
| Revenue by category, MoM | Audio +18% QoQ, driven by Q4 promotions |
| Return rate by segment | New customers return 2.3× more than repeat |
| 90-day repeat rate by channel | Organic search: 31%. Paid social: 9%. |

[link to dashboard] · [link to 1-pager PDF]

## The Stack

dbt · PostgreSQL · Power BI

## What's Next

SCD Type 2 on customer dimension · dbt tests · Airflow orchestration

---
*Code in `/models`. Full writeup in `/docs`.*
