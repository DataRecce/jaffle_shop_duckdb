with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

customer_orders as (

        select
        customer_id,

        min(order_date) as first_order,
        max(order_date) as most_recent_order,
        count(order_id) as number_of_orders
    from orders

    group by customer_id

),

customer_payments as (

    select
        orders.customer_id,
        sum(amount)::bigint as gross_amount, -- Includes coupon amount
        sum(amount - coupon_amount)::bigint as net_amount, -- Excludes coupon amount

    from payments

    left join orders on
         payments.order_id = orders.order_id
        and orders.status = 'completed'

    where payments.amount is not null -- Exclude incomplete payments
        and payments.amount > 0 -- Exclude negative amounts

    group by orders.customer_id

),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order,
        customer_orders.most_recent_order,
        customer_orders.number_of_orders,
        customer_payments.gross_amount as customer_lifetime_value, -- Gross CLV
        customer_payments.net_amount as net_customer_lifetime_value -- Net CLV

    from customers

    left join customer_orders
        on customers.customer_id = customer_orders.customer_id

    left join customer_payments
        on  customers.customer_id = customer_payments.customer_id

)

select * from final
