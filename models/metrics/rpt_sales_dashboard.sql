with weekly as (
    select * from {{ ref('metric_weekly_sales') }}
),

final as (
    select
        w.week_start,
        w.total_orders,
        w.total_revenue,
        w.net_revenue,
        w.total_margin,
        w.total_discounts,
        w.total_items_sold,
        w.avg_daily_order_value,
        lag(w.total_revenue) over (order by w.week_start) as prev_week_revenue,
        case when lag(w.total_revenue) over (order by w.week_start) > 0
            then round((w.total_revenue - lag(w.total_revenue) over (order by w.week_start))
                / lag(w.total_revenue) over (order by w.week_start) * 100, 1)
            else null
        end as revenue_wow_growth_pct
    from weekly w
)

select * from final
