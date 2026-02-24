with orders as (
    select * from {{ ref('int_order_enriched') }}
),

assignments as (
    select * from {{ ref('int_store_order_assignments') }}
),

summary as (
    select
        o.order_date,
        date_trunc('week', o.order_date) as order_week,
        date_trunc('month', o.order_date) as order_month,
        a.store_id,
        count(*) as order_count,
        sum(o.subtotal) as revenue,
        sum(o.total_cost) as cost,
        sum(o.total_margin) as margin,
        sum(o.discount_amount) as discounts,
        sum(o.subtotal) - sum(o.discount_amount) as net_revenue
    from orders o
    left join assignments a on o.order_id = a.order_id
    group by o.order_date, date_trunc('week', o.order_date),
             date_trunc('month', o.order_date), a.store_id
)

select * from summary
