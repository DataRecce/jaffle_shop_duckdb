with performance as (
    select * from {{ ref('store_performance') }}
),

ranked as (
    select
        store_id,
        store_name,
        city,
        state,
        total_revenue,
        total_margin,
        order_count,
        unique_customers,
        revenue_per_employee,
        rank() over (order by total_revenue desc) as revenue_rank,
        rank() over (order by total_margin desc) as margin_rank,
        rank() over (order by order_count desc) as order_count_rank,
        rank() over (order by revenue_per_employee desc) as efficiency_rank,
        rank() over (order by unique_customers desc) as customer_reach_rank
    from performance
)

select * from ranked
