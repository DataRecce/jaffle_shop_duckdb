# Expanded Jaffle Shop Design

**Date:** 2026-02-23
**Purpose:** Scale jaffle_shop_duckdb from 9 nodes to ~99 nodes for Recce demo/testing
**Approach:** Balanced e-commerce expansion (Approach 3)

## Goals

- ~100 dbt nodes with interesting interdependencies across 5 layers
- Diamond dependencies, fan-in/fan-out patterns for Recce lineage demos
- 2 incremental models (complex for Recce impact analysis)
- Interesting CTEs: recursive category hierarchy, RFM segmentation, window functions
- Keep DuckDB backend, keep existing models as foundation

## Seed Tables (12)

### Existing (unchanged)
| Seed | Rows | Schema |
|------|------|--------|
| raw_customers | 100 | id, first_name, last_name |
| raw_orders | 99 | id, user_id, order_date, status |
| raw_payments | 113 | id, order_id, payment_method, amount |

### New
| Seed | ~Rows | Schema |
|------|-------|--------|
| raw_products | 50 | id, name, category_id, price, cost, created_at |
| raw_categories | 10 | id, name, parent_category_id |
| raw_order_items | 250 | id, order_id, product_id, quantity, unit_price |
| raw_stores | 5 | id, name, city, state, opened_at |
| raw_employees | 30 | id, store_id, first_name, last_name, role, hired_at |
| raw_promotions | 15 | id, name, discount_type, discount_value, start_date, end_date |
| raw_order_promotions | 40 | order_id, promotion_id |
| raw_supply_orders | 60 | id, product_id, store_id, quantity, order_date, delivered_date |
| raw_reviews | 80 | id, order_id, product_id, customer_id, rating, review_date |

## Staging Layer (12 models, views)

One per seed. Rename columns, cast types, basic cleaning. Standard dbt staging pattern.

- stg_customers, stg_orders, stg_payments (existing)
- stg_products, stg_categories, stg_order_items, stg_stores, stg_employees
- stg_promotions, stg_order_promotions, stg_supply_orders, stg_reviews

## Intermediate Layer (25 models)

### Product domain (5)
- int_category_hierarchy: recursive CTE for category tree
- int_products_with_categories: products + full category path
- int_product_margins: margin = price - cost, margin %
- int_order_items_with_products: line items + product/category
- int_order_items_enriched: line items + margin data

### Order domain (5)
- int_order_totals: aggregate line items to order level
- int_order_payments_matched: payments matched to order totals, flag discrepancies
- int_orders_with_promotions: orders + discount data
- int_order_enriched: fan-in of totals + promotions + payment status
- int_daily_order_summary: **incremental** daily rollup

### Customer domain (5)
- int_customer_order_history: per-customer order stats
- int_customer_first_last_orders: first/last order dates (window functions)
- int_customer_payment_methods: payment method preferences
- int_customer_review_activity: review stats per customer
- int_customer_segments: **RFM segmentation CTE** with window functions

### Store & employee domain (4)
- int_store_employees_active: active employees per store
- int_store_order_assignments: orders assigned to stores
- int_store_revenue: revenue per store
- int_store_performance: revenue per employee, efficiency

### Supply chain (3)
- int_supply_order_costs: supply orders with costs
- int_inventory_movements: in (supply) vs out (sales) movements
- int_product_stock_levels: **incremental** running stock calculation

### Reviews (3)
- int_reviews_with_products: reviews + product/category
- int_product_ratings: avg rating, count per product
- int_promotion_effectiveness: promoted vs non-promoted order comparison

## Mart Layer (35 models, tables)

### Customer (8)
- customers (enhanced existing), customer_lifetime_value, customer_segments_final
- customer_retention, customer_acquisition, customer_360 (big fan-in)
- customer_cohorts, customer_review_summary

### Orders (7)
- orders (enhanced existing), order_items, order_returns
- order_discounts, order_fulfillment, order_payment_status, new_orders (existing)

### Products (6)
- products, product_performance, product_categories
- product_inventory, product_reviews, product_profitability

### Stores (5)
- stores, store_performance, store_staffing, store_inventory, store_rankings

### Finance (5)
- payments_fact, revenue_summary, promotion_roi, cost_analysis, gross_margin

### Supply chain (4)
- supply_orders_fact, supplier_lead_times, reorder_recommendations, inventory_health

## Reporting/Metrics Layer (15 models)

### Metrics (10)
- metric_daily_revenue, metric_daily_orders, metric_weekly_sales, metric_monthly_sales
- metric_customer_acquisition_monthly, metric_customer_retention_monthly
- metric_product_sales_daily, metric_store_daily, metric_promotion_daily, metric_inventory_daily

### Dashboards (5)
- rpt_executive_dashboard, rpt_sales_dashboard, rpt_customer_dashboard
- rpt_product_dashboard, rpt_store_dashboard

## Key Graph Patterns

- **Diamond**: stg_products -> int_products_with_categories + int_product_margins -> int_order_items_enriched
- **Deep fan-in**: customer_360 (4 inputs), rpt_executive_dashboard (3 inputs), int_order_enriched (3 inputs)
- **5 graph levels**: seed -> staging -> intermediate -> mart -> reporting
- **Cross-domain joins**: orders touch products, stores, promotions, payments
- **Incrementals**: int_daily_order_summary, int_product_stock_levels

## Node Count

| Layer | Count |
|-------|-------|
| Seeds | 12 |
| Staging | 12 |
| Intermediate | 25 |
| Mart | 35 |
| Reporting | 15 |
| **Total** | **99** |
