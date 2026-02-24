with monthly_sales as (
    select * from {{ ref('metric_monthly_sales') }}
),

segments as (
    select
        customer_segment,
        count(*) as customer_count,
        sum(total_spent) as segment_revenue
    from {{ ref('customer_segments_final') }}
    group by customer_segment
),

margin as (
    select
        sum(total_revenue) as total_revenue,
        sum(total_margin) as total_margin,
        sum(total_net_revenue) as total_net_revenue,
        round(sum(total_margin) / nullif(sum(total_revenue), 0) * 100, 1) as overall_margin_pct
    from {{ ref('gross_margin') }}
),

final as (
    select
        ms.month_start,
        ms.total_orders,
        ms.total_revenue,
        ms.net_revenue,
        ms.total_margin,
        m.overall_margin_pct,
        ms.total_items_sold,
        ms.active_days
    from monthly_sales ms
    cross join margin m
)

select * from final
