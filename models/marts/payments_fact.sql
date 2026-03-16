with payments as (
    select * from {{ ref('stg_payments') }}
),

orders as (
    select * from {{ ref('orders') }}
),

final as (
    select
        p.payment_id,
        p.order_id,
        o.customer_id,
        o.order_date,
        p.payment_method,
        p.amount,
        o.status as order_status
    from payments p
    left join orders o on p.order_id = o.order_id
)

select * from final
