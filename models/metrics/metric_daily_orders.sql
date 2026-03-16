with orders as (
    select * from {{ ref('int_order_enriched') }}
),

daily as (
    select
        order_date,
        count(*) as total_orders,
        sum(case when status in ('completed', 'Scompleted') then 1 else 0 end) as completed_orders,
        sum(case when status in ('returned', 'Sreturned', 'return_pending', 'Sreturn_pending') then 1 else 0 end) as returned_orders,
        sum(case when status in ('shipped', 'Sshipped') then 1 else 0 end) as shipped_orders,
        sum(case when status in ('placed', 'Splaced') then 1 else 0 end) as placed_orders,
        sum(case when has_promotion then 1 else 0 end) as promoted_orders,
        avg(item_count) as avg_items_per_order
    from orders
    group by order_date
)

select * from daily
