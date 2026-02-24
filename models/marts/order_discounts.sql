with orders as (
    select * from {{ ref('int_order_enriched') }}
),

discounts as (
    select
        order_id,
        customer_id,
        order_date,
        subtotal,
        has_promotion,
        promotion_name,
        discount_type,
        discount_value,
        discount_amount,
        case when subtotal > 0
            then round(discount_amount / subtotal * 100, 1)
            else 0
        end as discount_pct_of_order,
        subtotal - discount_amount as net_revenue
    from orders
    where has_promotion = true
)

select * from discounts
