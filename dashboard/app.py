"""
OpenBuild Analytics Engineering — Dashboard
Cohort retention, refund leakage, and channel mix
on a 4-year e-commerce dataset (108K orders, 87K users).
"""

import streamlit as st
import pandas as pd
import duckdb
from pathlib import Path

# ---------- Page config ----------
st.set_page_config(
    page_title="OpenBuild Analytics — Cohort, refund, and channel insights",
    page_icon=":material/insights:",
    layout="wide",
    initial_sidebar_state="expanded",
)
# ---------- Hide Streamlit branding for production polish ----------
st.markdown(
    """
    <style>
    /* Hide the 'Made with Streamlit' footer */
    footer {visibility: hidden;}
    /* Hide the top-right hamburger menu (Settings/About/Report bug — for development only) */
    #MainMenu {visibility: hidden;}
    /* Hide the 'Deploy' button that appears for app owners */
    .stDeployButton {display: none;}
    /* Tighten the top padding so content starts higher */
    .block-container {padding-top: 2rem;}
    </style>
    """,
    unsafe_allow_html=True,
)
# ---------- Data loading ----------
DATA_DIR = Path(__file__).parent.parent / "data" / "dashboard"

@st.cache_data
def load_marts():
    return {
        "cohort_retention": pd.read_csv(DATA_DIR / "mart_cohort_retention.csv"),
        "loyalty_retention": pd.read_csv(DATA_DIR / "mart_loyalty_retention.csv"),
        "refund_metrics": pd.read_csv(DATA_DIR / "mart_refund_metrics.csv"),
        "channel_revenue": pd.read_csv(DATA_DIR / "mart_channel_revenue.csv"),
        "marketing_acquisition": pd.read_csv(DATA_DIR / "mart_marketing_acquisition.csv"),
        "product_concentration": pd.read_csv(DATA_DIR / "mart_product_concentration.csv"),
        "dim_country": pd.read_csv(DATA_DIR / "dim_country.csv"),
        "dim_product": pd.read_csv(DATA_DIR / "dim_product.csv"),
        "first_purchase": pd.read_csv(DATA_DIR / "first_purchase_summary.csv"),
    }

# Surface any data-loading errors to the user instead of silently crashing the app
try:
    marts = load_marts()
except Exception as e:
    st.error("Failed to load data files.")
    st.code(f"DATA_DIR resolved to: {DATA_DIR}")
    st.code(f"Error: {type(e).__name__}: {e}")
    import os
    if DATA_DIR.exists():
        st.code(f"Files found in DATA_DIR: {os.listdir(DATA_DIR)}")
    else:
        st.code(f"DATA_DIR does not exist. Working dir: {os.getcwd()}")
        st.code(f"Files in working dir: {os.listdir('.')}")
    st.stop()

# ---------- Sidebar ----------
with st.sidebar:
    st.markdown("### E-commerce cohort, refund & channel insights")
    st.caption("Analytics engineering portfolio")
    st.markdown("---")
    page = st.radio(
        "Navigate",
        ["Overview", "Retention", "Refunds", "Channels", "Acquisition", "About"],
        label_visibility="collapsed",
    )
    st.markdown("---")
    st.caption(
        "[GitHub repo](https://github.com/joyce92200/ecommerce-analytics-engineering) · "
        "[Executive PDF](https://github.com/joyce92200/ecommerce-analytics-engineering/blob/main/docs/openbuild_findings_one_pager.pdf)"
    )

# ---------- Main content ----------
if page == "Overview":
    st.title("OpenBuild Retail Analytics")
    st.markdown(
        "End-to-end analytics layer for a mid-size electronics retailer. "
        "Medallion architecture · star schema · 37 tested transformations."
    )

    st.markdown("### Numbers at a glance")
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.metric("Orders", "108,124")
        st.caption("Jan 2019 – Dec 2022")
    with col2:
        st.metric("Users", "87,625")
        st.caption("Across 193 countries")
    with col3:
        st.metric("Revenue", "$25.9M")
        st.caption("Net of refunds")
    with col4:
        st.metric("Tests passing", "37 / 37")
        st.caption("All assertions")

    st.markdown("---")
    st.markdown("### Four findings")

    col_a, col_b = st.columns(2)
    with col_a:
        st.markdown("**Retention** — *Loyalty's deficit is a channel problem*")
        st.markdown(
            "Loyalty members retain **3.6× worse** than non-members at month 1. "
            "Mechanism: the **email channel** acquires 60% of loyalty members AND the lowest-AOV buyers. "
            "The program isn't broken — its acquisition channel is."
        )

        st.markdown("**Refunds** — *Laptops drive most of the leak*")
        st.markdown(
            "Refund baseline 4.97%. Laptops dominate top-10 worst segments. "
            "**MacBook Air × US** = largest dollar leak at $365K. "
            "Negative result: fulfillment-SLA correlation is weak — investment redirects to spec accuracy."
        )

    with col_b:
        st.markdown("**Channels** — *Mobile is a discovery surface*")
        st.markdown(
            "Website = **96.8% of revenue**. Mobile AOV is 6.4× lower than web. "
            "Even mobile-acquired users buy on web ~54% of the time — "
            "mobile functions as discovery, not transaction."
        )

        st.markdown("**Concentration** — *Top-3 dominate, bottom-5 wasted*")
        st.markdown(
            "Top 3 products = **85% of revenue**: Gaming Monitor, AirPods, MacBook Air. "
            "Bottom 5 = under 5%. Two opposite problems: dangerous concentration AND wasteful fragmentation."
        )

elif page == "Retention":
    st.title("Retention")
    st.markdown(
        "Cohort retention is structurally flat. Loyalty members retain **3.6× worse** than non-members — "
        "a gap that emerged in 2020 alongside aggressive program scaling."
    )

    st.markdown("---")

    loyalty_df = marts["loyalty_retention"]

    # ----- Filter controls -----
    col_filter1, col_filter2 = st.columns([1, 2])
    with col_filter1:
        loyalty_df["cohort_year"] = pd.to_datetime(loyalty_df["cohort_month"]).dt.year
        years = ["All cohorts (2019–2022)"] + sorted(loyalty_df["cohort_year"].unique().tolist())
        selected_year = st.selectbox("Cohort year", years, label_visibility="visible")

    with col_filter2:
        max_month = int(loyalty_df["months_since_acquisition"].max())
        months_horizon = st.slider("Months since acquisition", 1, max_month, 12)

    # Apply filters
    if selected_year == "All cohorts (2019–2022)":
        filtered = loyalty_df.copy()
    else:
        filtered = loyalty_df[loyalty_df["cohort_year"] == selected_year].copy()

    filtered = filtered[
        (filtered["months_since_acquisition"] >= 1)
        & (filtered["months_since_acquisition"] <= months_horizon)
    ]

    # ----- KPI strip -----
    month1 = filtered[filtered["months_since_acquisition"] == 1]
    nl_m1 = month1[month1["loyalty_status"] == 0]["retention_pct"].mean()
    l_m1 = month1[month1["loyalty_status"] == 1]["retention_pct"].mean()
    deficit = nl_m1 / l_m1 if l_m1 > 0 else float("inf")

    k1, k2, k3 = st.columns(3)
    with k1:
        st.metric("Non-loyalty month-1", f"{nl_m1:.2f}%")
    with k2:
        st.metric("Loyalty month-1", f"{l_m1:.2f}%")
    with k3:
        st.metric("Deficit ratio", f"{deficit:.1f}×")

    # ----- Chart 1: retention curves -----
    st.markdown("### Retention curves")
    curve_data = (
        filtered.groupby(["months_since_acquisition", "loyalty_status"])["retention_pct"]
        .mean()
        .reset_index()
    )
    pivot_curves = curve_data.pivot(
        index="months_since_acquisition",
        columns="loyalty_status",
        values="retention_pct",
    )
    pivot_curves.columns = ["Non-loyalty", "Loyalty"]
    st.line_chart(pivot_curves, color=["#185FA5", "#EF9F27"])
    st.caption(
        "Retention rate (%) by months since acquisition. "
        "Non-loyalty in blue, loyalty in amber."
    )

    # ----- Chart 2: yearly month-1 comparison -----
    st.markdown("### Month-1 retention by cohort year")
    yearly_data = (
        loyalty_df[loyalty_df["months_since_acquisition"] == 1]
        .groupby(["cohort_year", "loyalty_status"])["retention_pct"]
        .mean()
        .reset_index()
    )
    pivot_yearly = yearly_data.pivot(
        index="cohort_year",
        columns="loyalty_status",
        values="retention_pct",
    )
    pivot_yearly.columns = ["Non-loyalty", "Loyalty"]
    st.bar_chart(pivot_yearly, color=["#185FA5", "#EF9F27"])
    st.caption(
        "The structural break: 2019 gap was small (1.55% vs. 1.35%). "
        "From 2020 onward the deficit is 4–6× and persists."
    )

    # ----- What this means -----
    st.markdown("---")
    st.markdown("### What this means")
    st.markdown(
        """
        **The mechanism is product mix, not discounting.** AOVs at first purchase are nearly equal
        ($239 loyalty vs. $257 non-loyalty), so the program is not bargain-hunter selection.

        Loyalty members' first purchases skew heavily toward **Apple Airpods (58.3% vs. 36.6%)** and
        underweight **Samsung Charging Cable Pack (5.7% vs. 34.0%)** — the only replenishable
        product in the catalog. Loyalty is recruiting one-and-done buyers at scale.

        **Implication:** Recruitment mechanics, not the program's points/discount structure, are
        the lever. The program needs to steer signups toward replenishable categories.
        """
    )

elif page == "Refunds":
    st.title("Refunds")
    st.markdown(
        "Refund baseline is **4.97%** of all orders. **Laptops drive 2.5–4.3× the company rate** — "
        "every segment in the top 10 worst is a laptop. The largest dollar leak is **MacBook Air × US** at $365K refunded."
    )

    st.markdown("---")

    refund_df = marts["refund_metrics"]

    # ----- Filter controls -----
    col_filter1, col_filter2, col_filter3 = st.columns([1, 1, 1])

    with col_filter1:
        products = ["All products"] + sorted(refund_df["product_name"].unique().tolist())
        selected_product = st.selectbox("Product", products)

    with col_filter2:
        countries = ["All countries"] + sorted(
            refund_df["country_code"].dropna().unique().tolist()
        )
        selected_country = st.selectbox("Country", countries)

    with col_filter3:
        min_orders = st.slider(
            "Minimum orders per segment",
            min_value=1,
            max_value=500,
            value=100,
            help="Filter out small segments. Default = 100 for statistical reliability."
        )

    # Apply filters
    filtered = refund_df[refund_df["orders"] >= min_orders].copy()
    if selected_product != "All products":
        filtered = filtered[filtered["product_name"] == selected_product]
    if selected_country != "All countries":
        filtered = filtered[filtered["country_code"] == selected_country]

    # ----- KPI strip -----
    if len(filtered) > 0:
        avg_rate = filtered["refund_rate_pct"].mean()
        total_refunded = filtered["refunded_revenue_usd"].sum()
        worst_rate = filtered["refund_rate_pct"].max()

        k1, k2, k3 = st.columns(3)
        with k1:
            st.metric("Avg refund rate", f"{avg_rate:.2f}%")
        with k2:
            st.metric("Total $ refunded", f"${total_refunded:,.0f}")
        with k3:
            st.metric("Worst segment rate", f"{worst_rate:.2f}%")
    else:
        st.warning("No segments match the current filters. Try lowering the minimum orders threshold.")

    # ----- Chart: top segments by refund rate -----
    if len(filtered) > 0:
        st.markdown("### Top 10 segments by refund rate")
        top10 = filtered.nlargest(10, "refund_rate_pct")[
            ["product_name", "country_code", "refund_rate_pct", "refunded_revenue_usd", "orders"]
        ].copy()
        top10["segment"] = top10["product_name"] + " × " + top10["country_code"].fillna("(NULL)")

        # Bar chart sorted ascending so largest is on top
        chart_data = top10.set_index("segment")[["refund_rate_pct"]].iloc[::-1]
        st.bar_chart(chart_data, color="#185FA5", horizontal=True)
        st.caption(
            "Refund rate (%). Color intensity is uniform; hover bars to see exact values. "
            "Segments are filtered by ≥100 orders by default."
        )

        # ----- Drill-down table -----
        st.markdown("### Drill-down")
        display_df = top10[["segment", "orders", "refund_rate_pct", "refunded_revenue_usd"]].copy()
        display_df.columns = ["Segment", "Orders", "Refund rate (%)", "Refunded revenue (USD)"]
        display_df["Refunded revenue (USD)"] = display_df["Refunded revenue (USD)"].apply(
            lambda x: f"${x:,.0f}"
        )
        display_df["Refund rate (%)"] = display_df["Refund rate (%)"].apply(lambda x: f"{x:.2f}%")
        display_df["Orders"] = display_df["Orders"].apply(lambda x: f"{x:,}")
        st.dataframe(display_df, hide_index=True, use_container_width=True)

    # ----- What this means -----
    st.markdown("---")
    st.markdown("### What this means")
    st.markdown(
        """
        **All top-10 worst segments are laptops.** Refund-reduction initiatives should target laptops first —
        not accessories.

        **Geographic variation matters.** ThinkPad refunds at 21.3% in Canada but only 12.9% in the US — an 8.4
        percentage-point gap on the same product. This suggests fulfillment or returns-policy variance by country
        rather than a universal product-quality issue.

        **Largest dollar leak ≠ worst rate.** MacBook Air × US has a moderate 12.4% rate, but it's the single
        largest absolute leak ($365K refunded) because of high volume. Rate alone misranks priorities for
        revenue protection.
        """
    )

elif page == "Channels":
    st.title("Channels")
    st.markdown(
        "Website is **96.8% of lifetime revenue** ($25.0M of $25.9M). Mobile generates **17% of orders "
        "but only 3% of revenue** — a structurally low-AOV channel where the lever is order value, not order volume."
    )

    st.markdown("---")

    channel_df = marts["channel_revenue"]
    channel_df["purchase_month"] = pd.to_datetime(channel_df["purchase_month"])
    channel_df["year"] = channel_df["purchase_month"].dt.year

    # ----- Filter controls -----
    col_filter1, col_filter2 = st.columns([2, 1])

    with col_filter1:
        years_available = sorted(channel_df["year"].unique().tolist())
        year_range = st.select_slider(
            "Year range",
            options=years_available,
            value=(years_available[0], years_available[-1]),
        )

    with col_filter2:
        platforms = ["Both"] + sorted(channel_df["purchase_platform"].unique().tolist())
        selected_platform = st.selectbox("Platform", platforms)

    # Apply filters
    filtered = channel_df[
        (channel_df["year"] >= year_range[0]) & (channel_df["year"] <= year_range[1])
    ].copy()
    if selected_platform != "Both":
        filtered = filtered[filtered["purchase_platform"] == selected_platform]

    # ----- KPI strip -----
    web_rev = filtered[filtered["purchase_platform"] == "website"]["net_revenue_usd"].sum()
    mob_rev = filtered[filtered["purchase_platform"] == "mobile app"]["net_revenue_usd"].sum()
    total_rev = web_rev + mob_rev
    web_share = (web_rev / total_rev * 100) if total_rev > 0 else 0

    web_orders = filtered[filtered["purchase_platform"] == "website"]["orders"].sum()
    mob_orders = filtered[filtered["purchase_platform"] == "mobile app"]["orders"].sum()

    web_aov = (web_rev / web_orders) if web_orders > 0 else 0
    mob_aov = (mob_rev / mob_orders) if mob_orders > 0 else 0
    aov_ratio = (web_aov / mob_aov) if mob_aov > 0 else float("inf")

    k1, k2, k3, k4 = st.columns(4)
    with k1:
        st.metric("Total revenue", f"${total_rev/1e6:.1f}M")
    with k2:
        st.metric("Website share", f"{web_share:.1f}%")
    with k3:
        st.metric("Web AOV", f"${web_aov:.0f}")
    with k4:
        st.metric("AOV ratio (web vs mobile)", f"{aov_ratio:.1f}×")

    # ----- Chart: monthly revenue by platform -----
    st.markdown("### Monthly net revenue by platform")
    chart_data = filtered.pivot(
        index="purchase_month",
        columns="purchase_platform",
        values="net_revenue_usd",
    ).fillna(0)
    # Map colors by column so it works regardless of which platforms are filtered in
    color_map = {"mobile app": "#EF9F27", "website": "#185FA5"}
    st.area_chart(
        chart_data,
        color=[color_map[col] for col in chart_data.columns],
    )
    st.caption(
        "Net revenue (USD) per month, stacked by platform. "
        "Mobile app (amber) sits as a thin band on top — flat across 4 years."
    )

    # ----- Chart: yearly platform share -----
    st.markdown("### Yearly platform share")
    yearly = (
        filtered.groupby(["year", "purchase_platform"])["net_revenue_usd"]
        .sum()
        .reset_index()
    )
    yearly_pivot = yearly.pivot(
        index="year",
        columns="purchase_platform",
        values="net_revenue_usd",
    ).fillna(0)
    yearly_pivot["total"] = yearly_pivot.sum(axis=1)
    yearly_share = yearly_pivot.div(yearly_pivot["total"], axis=0) * 100
    # Drop the 'total' helper column; keep whichever platform columns survived filtering
    yearly_share = yearly_share.drop(columns=["total"])
    st.bar_chart(
    yearly_share,
    color=[color_map[col] for col in yearly_share.columns],
)
    st.caption(
        "Platform share (%) of revenue per year. "
        "Mobile share moved from 2.95% (2019) to 3.93% (2022) — statistically real, business-trivially small."
    )

    # ----- What this means -----
    st.markdown("---")
    st.markdown("### What this means")
    st.markdown(
        """
        **Mobile is structurally a low-AOV channel.** With web AOV roughly 5× higher than mobile AOV,
        adding mobile order volume produces marginal revenue growth.

        **Doubling mobile orders only adds ~3 percentage points to total revenue at current AOV.**
        Mobile investment must target AOV — checkout UX for high-value items, mobile-friendly
        product pages for laptops and monitors — rather than acquisition volume.

        **Why is mobile AOV lower?** Mobile users skew toward accessory purchases (cables, headphones)
        while desktop users handle large/considered purchases (laptops, monitors). The catalog itself
        is desktop-shaped — high-AOV products have <5% mobile order share.
        """
    )
elif page == "Acquisition":
    st.title("Acquisition")
    st.markdown(
        "Two findings traced to *what gets acquired* and *what gets sold*. "
        "First: the **email channel** is over-recruiting loyalty members AND under-recruiting on AOV — "
        "the mechanism behind Finding 1's retention deficit. Second: the **catalog is dangerously concentrated** "
        "(top 3 = 85% of revenue) AND **wastefully fragmented** (bottom 5 = under 5%)."
    )

    st.markdown("---")

    # ============================================================
    # SECTION 1 — Marketing channel × loyalty acquisition
    # ============================================================
    st.markdown("## Marketing channel acquisition")
    st.caption("How each channel's user mix and AOV at acquisition shapes downstream loyalty retention")

    mkt_df = marts["marketing_acquisition"]

    # Filter to meaningful-volume channels
    big_channels = ['direct', 'email', 'affiliate', 'social media']
    mkt_filtered = mkt_df[mkt_df['marketing_channel'].isin(big_channels)].copy()

    # KPI strip — 3 cards anchoring the email-channel anomaly
    email_loyalty_pct = mkt_filtered[
        (mkt_filtered['marketing_channel'] == 'email')
        & (mkt_filtered['loyalty_status'] == 1)
    ]['pct_within_channel'].iloc[0]
    direct_loyalty_pct = mkt_filtered[
        (mkt_filtered['marketing_channel'] == 'direct')
        & (mkt_filtered['loyalty_status'] == 1)
    ]['pct_within_channel'].iloc[0]
    email_loyalty_aov = mkt_filtered[
        (mkt_filtered['marketing_channel'] == 'email')
        & (mkt_filtered['loyalty_status'] == 1)
    ]['avg_first_aov'].iloc[0]

    k1, k2, k3 = st.columns(3)
    with k1:
        st.metric("Email loyalty share", f"{email_loyalty_pct:.0f}%")
        st.caption("vs. direct's ~42%")
    with k2:
        st.metric("Direct loyalty share", f"{direct_loyalty_pct:.0f}%")
        st.caption("baseline channel")
    with k3:
        st.metric("Email loyalty AOV", f"${email_loyalty_aov:.0f}")
        st.caption("lowest of any channel × loyalty combo")

    # Chart 1 — Loyalty share by channel (stacked horizontal bar)
    st.markdown("### Loyalty share by acquisition channel")
    loyalty_pivot = mkt_filtered.pivot(
        index='marketing_channel', columns='loyalty_status',
        values='pct_within_channel'
    ).reindex(big_channels)
    loyalty_pivot.columns = ['Non-loyalty', 'Loyalty']
    st.bar_chart(loyalty_pivot, color=["#185FA5", "#EF9F27"], horizontal=True)
    st.caption(
        "Each channel sums to 100%. Email is the only channel where loyalty (60%) dominates. "
        "Direct is split roughly 60/40 non-loyalty/loyalty. Affiliate is 82% non-loyalty."
    )

    # Chart 2 — AOV by channel × loyalty (paired bars)
    st.markdown("### First-purchase AOV by channel × loyalty")
    aov_pivot = mkt_filtered.pivot(
        index='marketing_channel', columns='loyalty_status',
        values='avg_first_aov'
    ).reindex(big_channels)
    aov_pivot.columns = ['Non-loyalty', 'Loyalty']
    st.bar_chart(aov_pivot, color=["#185FA5", "#EF9F27"])
    st.caption(
        "AOV at first purchase by channel. Email AOVs are the lowest across both segments — "
        "email is doing two things wrong simultaneously: over-recruiting into loyalty AND under-recruiting on value."
    )

    # Drill-down table
    st.markdown("### Channel × loyalty drill-down")
    display_df = mkt_filtered[[
        'marketing_channel', 'loyalty_status', 'users_acquired',
        'avg_first_aov', 'pct_within_channel'
    ]].copy()
    display_df['loyalty_status'] = display_df['loyalty_status'].map({0: 'Non-loyalty', 1: 'Loyalty'})
    display_df['avg_first_aov'] = display_df['avg_first_aov'].apply(lambda x: f"${x:.0f}")
    display_df['pct_within_channel'] = display_df['pct_within_channel'].apply(lambda x: f"{x:.1f}%")
    display_df['users_acquired'] = display_df['users_acquired'].apply(lambda x: f"{x:,}")
    display_df.columns = ['Channel', 'Segment', 'Users acquired', 'AOV at first purchase', 'Share within channel']
    st.dataframe(display_df, hide_index=True, use_container_width=True)

    st.markdown("---")

    # ============================================================
    # SECTION 2 — Product concentration (Pareto)
    # ============================================================
    st.markdown("## Product concentration")
    st.caption("Two opposite problems coexist: dangerous concentration at the top, wasteful fragmentation at the bottom")

    pareto_df = marts["product_concentration"].copy()
    pareto_df = pareto_df.sort_values('net_revenue', ascending=False).reset_index(drop=True)

    # KPI strip
    top3_share = pareto_df.head(3)['pct_of_revenue'].sum()
    bottom5_share = pareto_df.tail(5)['pct_of_revenue'].sum()
    top1_product = pareto_df.iloc[0]['product_name']
    top1_share = pareto_df.iloc[0]['pct_of_revenue']

    k1, k2, k3 = st.columns(3)
    with k1:
        st.metric("Top 3 products share", f"{top3_share:.1f}%")
        st.caption("of total revenue")
    with k2:
        st.metric("Bottom 5 products share", f"{bottom5_share:.1f}%")
        st.caption("of total revenue")
    with k3:
        st.metric(top1_product, f"{top1_share:.1f}%")
        st.caption("largest single revenue driver")

    # Chart — Pareto: revenue bars + cumulative line
    st.markdown("### Revenue distribution (Pareto)")
    chart_data = pareto_df.set_index('product_name')[['net_revenue']]
    chart_data['net_revenue'] = chart_data['net_revenue'] / 1_000_000  # to millions
    chart_data.columns = ['Revenue ($M)']
    st.bar_chart(chart_data, color="#185FA5")

    # Cumulative line as separate chart
    st.markdown("### Cumulative revenue share")
    cum_data = pareto_df.set_index('product_name')[['cumulative_pct_of_revenue']]
    cum_data.columns = ['Cumulative %']
    st.line_chart(cum_data, color="#A32D2D")
    st.caption(
        "Top 3 products break the 80% Pareto threshold. Beyond the 4th product, additions to "
        "cumulative revenue are negligible — the long tail consumes ops complexity without delivering value."
    )

    # Drill-down table
    st.markdown("### Per-product breakdown")
    pareto_display = pareto_df[[
        'product_name', 'orders', 'net_revenue', 'avg_aov',
        'pct_of_revenue', 'cumulative_pct_of_revenue'
    ]].copy()
    pareto_display['orders'] = pareto_display['orders'].apply(lambda x: f"{x:,}")
    pareto_display['net_revenue'] = pareto_display['net_revenue'].apply(lambda x: f"${x:,.0f}")
    pareto_display['avg_aov'] = pareto_display['avg_aov'].apply(lambda x: f"${x:.0f}")
    pareto_display['pct_of_revenue'] = pareto_display['pct_of_revenue'].apply(lambda x: f"{x:.2f}%")
    pareto_display['cumulative_pct_of_revenue'] = pareto_display['cumulative_pct_of_revenue'].apply(lambda x: f"{x:.1f}%")
    pareto_display.columns = ['Product', 'Orders', 'Net revenue', 'AOV', '% of revenue', 'Cumulative %']
    st.dataframe(pareto_display, hide_index=True, use_container_width=True)

    # What this means
    st.markdown("---")
    st.markdown("### What this means")
    st.markdown(
        """
        **Two opposite strategic problems coexist.** The top is dangerously concentrated —
        any supplier change in Apple, Samsung, or the monitor product cycle would erase 20-35%
        of revenue overnight. The bottom is wastefully fragmented — five products consume catalog
        real estate, ops complexity, and inventory dollars while contributing negligibly.

        **The Apple iPhone case is interesting.** Despite a $688 AOV (high price-point appeal),
        it accounts for just 0.8% of revenue. Either it's a quiet opportunity that lacks marketing
        investment, OR it's a dead SKU with no demand. The current data can't tell us which —
        a discoverability test (paid ads, homepage feature) is the next analytical step.

        **Strategic priority:** Rationalize the bottom (kill or aggressively scale Bose, iPhone)
        while diversifying the top to reduce single-supplier risk.
        """
    )
elif page == "About":
    st.title("About")
    st.markdown(
        """
        This dashboard is the interactive layer over an analytics engineering project that models
        a 4-year e-commerce dataset using a medallion architecture (bronze → silver → gold) and
        a star schema (4 dimensions + 1 fact + 4 marts).

        **Built with**: DuckDB · pandas · Streamlit · Jupyter · SQL · Git
        **Tests**: 32 SQL assertions covering schema, uniqueness, referential integrity, and derivation invariants
        **Source data**: Public e-commerce orders dataset, 108K orders × 87K users × 193 countries

        Full code, methodology, and tests at the GitHub link in the sidebar.
        """
    )
# ---------- Footer (renders on every page) ----------
st.markdown("---")
footer_col1, footer_col2, footer_col3 = st.columns([1, 1, 1])

with footer_col1:
    st.markdown(
        '<p style="color:#888780; font-size:13px;">'
        '<span style="background:#E1F5EE; color:#0F6E56; padding:2px 8px; border-radius:4px; font-weight:500;">'
        '✓ 37/37 tests passing'
        '</span></p>',
        unsafe_allow_html=True
    )

with footer_col2:
    st.markdown(
        '<p style="color:#888780; font-size:13px;">'
        '<a href="https://github.com/joyce92200/ecommerce-analytics-engineering" target="_blank" '
        'style="color:#185FA5; text-decoration:none;">View source on GitHub →</a>'
        '</p>',
        unsafe_allow_html=True
    )

with footer_col3:
    st.markdown(
        '<p style="color:#888780; font-size:13px;">'
        '<a href="https://github.com/joyce92200/ecommerce-analytics-engineering/blob/main/docs/openbuild_findings_one_pager.pdf" target="_blank" '
        'style="color:#185FA5; text-decoration:none;">Executive 1-pager (PDF) →</a>'
        '</p>',
        unsafe_allow_html=True
    )