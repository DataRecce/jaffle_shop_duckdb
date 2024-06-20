select
    orders.customer_id,
    sum(amount)::bigint as total_amount

from {{ ref('stg_payments') }} payments

left join {{ ref('stg_orders') }} orders on
     payments.order_id = orders.order_id

group by orders.customer_id
