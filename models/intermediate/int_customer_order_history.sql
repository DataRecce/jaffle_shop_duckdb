with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('int_order_enriched') }}
),

history as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        count(o.order_id) as total_orders,
        coalesce(sum(o.subtotal), 0) as total_spent,
        coalesce(sum(o.total_margin), 0) as total_margin_generated,
        coalesce(avg(o.subtotal), 0) as avg_order_value,
        coalesce(sum(o.total_quantity), 0) as total_items_purchased,
        count(distinct o.order_date) as distinct_order_days
    from customers c
    left join orders o on c.customer_id = o.customer_id
    group by c.customer_id, c.first_name, c.last_name
)

select * from history
