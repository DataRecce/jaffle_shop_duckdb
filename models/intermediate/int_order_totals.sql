with enriched_items as (
    select * from {{ ref('int_order_items_enriched') }}
),

order_aggs as (
    select
        order_id,
        count(*) as item_count,
        sum(quantity) as total_quantity,
        sum(line_total) as subtotal,
        sum(line_cost) as total_cost,
        sum(line_margin) as total_margin,
        count(distinct root_category) as category_count
    from enriched_items
    group by order_id
)

select * from order_aggs
