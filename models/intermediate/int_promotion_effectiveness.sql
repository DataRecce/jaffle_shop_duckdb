with orders_with_promos as (
    select * from {{ ref('int_orders_with_promotions') }}
),

order_totals as (
    select * from {{ ref('int_order_totals') }}
),

effectiveness as (
    select
        owp.has_promotion,
        owp.promotion_name,
        owp.discount_type,
        count(*) as order_count,
        avg(ot.subtotal) as avg_order_value,
        sum(ot.subtotal) as total_revenue,
        avg(ot.item_count) as avg_items_per_order,
        avg(ot.total_margin) as avg_margin
    from orders_with_promos owp
    left join order_totals ot on owp.order_id = ot.order_id
    group by owp.has_promotion, owp.promotion_name, owp.discount_type
)

select * from effectiveness
