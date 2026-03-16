with revenue as (
    select * from {{ ref('revenue_summary') }}
),

margin_summary as (
    select
        order_month,
        store_id,
        sum(revenue) as total_revenue,
        sum(cost) as total_cost,
        sum(margin) as total_margin,
        sum(discounts) as total_discounts,
        sum(net_revenue) as total_net_revenue,
        case when sum(revenue) > 0
            then round(sum(margin) / sum(revenue) * 100, 1)
            else 0
        end as gross_margin_pct,
        sum(order_count) as total_orders
    from revenue
    group by order_month, store_id
)

select * from margin_summary
