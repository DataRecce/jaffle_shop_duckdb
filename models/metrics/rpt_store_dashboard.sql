with rankings as (
    select * from {{ ref('store_rankings') }}
),

inventory as (
    select * from {{ ref('store_inventory') }}
),

daily as (
    select
        store_id,
        count(distinct order_date) as active_days,
        avg(revenue) as avg_daily_revenue
    from {{ ref('metric_store_daily') }}
    group by store_id
),

dashboard as (
    select
        r.store_id,
        r.store_name,
        r.city,
        r.state,
        r.total_revenue,
        r.total_margin,
        r.order_count,
        r.unique_customers,
        r.revenue_per_employee,
        r.revenue_rank,
        r.efficiency_rank,
        i.total_stock_units,
        i.out_of_stock_products,
        i.low_stock_products,
        d.active_days,
        d.avg_daily_revenue
    from rankings r
    left join inventory i on r.store_id = i.store_id
    left join daily d on r.store_id = d.store_id
)

select * from dashboard
