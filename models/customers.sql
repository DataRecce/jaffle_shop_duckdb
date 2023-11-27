select
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customer_orders.first_order,
    customer_orders.most_recent_order,
    customer_orders.number_of_orders,
    customer_payments.total_amount as customer_lifetime_value

from {{ ref('stg_customers') }} customers

left join {{ ref('int_customer_orders') }} customer_orders
    on customers.customer_id = customer_orders.customer_id

left join {{ ref('int_customer_payments') }} customer_payments
    on  customers.customer_id = customer_payments.customer_id
