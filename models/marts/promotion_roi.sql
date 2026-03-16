with effectiveness as (
    select * from {{ ref('int_promotion_effectiveness') }}
),

discounts as (
    select
        promotion_name,
        count(*) as usage_count,
        sum(discount_amount) as total_discount_given,
        sum(net_revenue) as total_net_revenue
    from {{ ref('order_discounts') }}
    group by promotion_name
),

roi as (
    select
        e.promotion_name,
        e.discount_type,
        e.order_count,
        e.avg_order_value,
        e.total_revenue,
        e.avg_margin,
        coalesce(d.total_discount_given, 0) as total_discount_given,
        coalesce(d.total_net_revenue, 0) as net_revenue_after_discount,
        case when coalesce(d.total_discount_given, 0) > 0
            then round(coalesce(d.total_net_revenue, 0) / d.total_discount_given, 2)
            else 0
        end as revenue_per_discount_dollar
    from effectiveness e
    left join discounts d on e.promotion_name = d.promotion_name
    where e.has_promotion = true
)

select * from roi
