with orders_promos as (
    select * from {{ ref('int_orders_with_promotions') }}
),

order_totals as (
    select * from {{ ref('int_order_totals') }}
),

payment_status as (
    select * from {{ ref('int_order_payments_matched') }}
),

enriched as (
    select
        op.order_id,
        op.customer_id,
        op.order_date,
        op.status,
        ot.item_count,
        ot.total_quantity,
        ot.subtotal,
        ot.total_cost,
        ot.total_margin,
        ot.category_count,
        op.has_promotion,
        op.promotion_name,
        op.discount_type,
        op.discount_value,
        ps.total_paid,
        ps.payment_count,
        ps.payment_status,
        case
            when op.discount_type = 'percentage' then round(ot.subtotal * op.discount_value / 100, 2)
            when op.discount_type = 'fixed' then op.discount_value / 100.0
            else 0
        end as discount_amount
    from orders_promos op
    left join order_totals ot on op.order_id = ot.order_id
    left join payment_status ps on op.order_id = ps.order_id
)

select * from enriched
