 with payments as (
    select * from {{ ref('stg_payments') }}
),

payments_revenue as (
    select
        order_id,
        sum(amount) as gross_revenue,
        sum(amount - coupon_amount) as net_revenue
    from payments
    group by order_id
),

orders as (
    select * from {{ ref('stg_orders') }}
),

final as (  
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        payments_revenue.gross_revenue,
        payments_revenue.net_revenue
    from orders
    left join payments_revenue
        on orders.order_id = payments_revenue.order_id
)

select * from final
