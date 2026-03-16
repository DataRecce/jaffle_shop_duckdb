with items as (
    select * from {{ ref('order_items') }}
),

orders as (
    select order_id, order_date from {{ ref('int_order_enriched') }}
),

daily_product as (
    select
        o.order_date,
        i.product_id,
        i.product_name,
        i.category_name,
        sum(i.quantity) as units_sold,
        sum(i.line_total) as revenue,
        sum(i.line_margin) as margin,
        count(distinct o.order_id) as order_count
    from items i
    inner join orders o on i.order_id = o.order_id
    group by o.order_date, i.product_id, i.product_name, i.category_name
)

select * from daily_product
