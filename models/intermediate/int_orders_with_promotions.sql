with orders as (
    select * from {{ ref('stg_orders') }}
),

order_promotions as (
    select * from {{ ref('stg_order_promotions') }}
),

promotions as (
    select * from {{ ref('stg_promotions') }}
),

joined as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        op.promotion_id,
        p.promotion_name,
        p.discount_type,
        p.discount_value,
        case when op.promotion_id is not null then true else false end as has_promotion
    from orders o
    left join order_promotions op on o.order_id = op.order_id
    left join promotions p on op.promotion_id = p.promotion_id
)

select * from joined
