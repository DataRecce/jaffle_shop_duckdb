with assignments as (
    select * from {{ ref('int_store_order_assignments') }}
),

orders as (
    select * from {{ ref('int_order_enriched') }}
),

store_rev as (
    select
        a.store_id,
        count(distinct a.order_id) as order_count,
        count(distinct a.customer_id) as unique_customers,
        sum(o.subtotal) as total_revenue,
        sum(o.total_cost) as total_cost,
        sum(o.total_margin) as total_margin,
        avg(o.subtotal) as avg_order_value
    from assignments a
    inner join orders o on a.order_id = o.order_id
    group by a.store_id
)

select * from store_rev
