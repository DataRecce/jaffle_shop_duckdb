with daily as (
    select * from {{ ref('int_daily_order_summary') }}
),

final as (
    select
        order_date,
        order_count,
        total_revenue,
        total_cost,
        total_margin,
        total_discounts,
        total_revenue - total_discounts as net_revenue,
        avg_order_value,
        unique_customers,
        total_items_sold
    from daily
)

select * from final
