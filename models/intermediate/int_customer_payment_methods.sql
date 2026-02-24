with payments as (
    select * from {{ ref('stg_payments') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_payments as (
    select
        o.customer_id,
        p.payment_method,
        count(*) as usage_count,
        sum(p.amount) as total_amount
    from payments p
    inner join orders o on p.order_id = o.order_id
    group by o.customer_id, p.payment_method
),

pivoted as (
    select
        customer_id,
        sum(case when payment_method = 'credit_card' then total_amount else 0 end) as credit_card_total,
        sum(case when payment_method = 'bank_transfer' then total_amount else 0 end) as bank_transfer_total,
        sum(case when payment_method = 'coupon' then total_amount else 0 end) as coupon_total,
        sum(case when payment_method = 'gift_card' then total_amount else 0 end) as gift_card_total,
        first(payment_method order by usage_count desc) as preferred_payment_method
    from customer_payments
    group by customer_id
)

select * from pivoted
