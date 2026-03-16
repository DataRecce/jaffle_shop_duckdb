with daily as (
    select * from {{ ref('metric_daily_revenue') }}
),

monthly as (
    select
        date_trunc('month', order_date) as month_start,
        sum(order_count) as total_orders,
        sum(total_revenue) as total_revenue,
        sum(net_revenue) as net_revenue,
        sum(total_margin) as total_margin,
        sum(total_discounts) as total_discounts,
        avg(avg_order_value) as avg_daily_order_value,
        sum(total_items_sold) as total_items_sold,
        count(distinct order_date) as active_days
    from daily
    group by date_trunc('month', order_date)
)

select * from monthly
