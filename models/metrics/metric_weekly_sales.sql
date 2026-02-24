with daily as (
    select * from {{ ref('metric_daily_revenue') }}
),

weekly as (
    select
        date_trunc('week', order_date) as week_start,
        sum(order_count) as total_orders,
        sum(total_revenue) as total_revenue,
        sum(net_revenue) as net_revenue,
        sum(total_margin) as total_margin,
        sum(total_discounts) as total_discounts,
        sum(unique_customers) as total_customer_visits,
        avg(avg_order_value) as avg_daily_order_value,
        sum(total_items_sold) as total_items_sold
    from daily
    group by date_trunc('week', order_date)
)

select * from weekly
