with orders as (
    select * from {{ ref('int_order_enriched') }}
),

first_last as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        max(order_date) - min(order_date) as customer_tenure_days,
        count(*) as lifetime_orders,
        (select max(order_date) from orders) - max(order_date) as days_since_last_order
    from orders
    group by customer_id
)

select * from first_last
