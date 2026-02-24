with discounts as (
    select * from {{ ref('order_discounts') }}
),

daily as (
    select
        order_date,
        promotion_name,
        discount_type,
        count(*) as usage_count,
        sum(discount_amount) as total_discount,
        sum(subtotal) as total_order_value,
        sum(net_revenue) as total_net_revenue,
        avg(discount_pct_of_order) as avg_discount_pct
    from discounts
    group by order_date, promotion_name, discount_type
)

select * from daily
