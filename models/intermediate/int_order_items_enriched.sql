with items as (
    select * from {{ ref('int_order_items_with_products') }}
),

margins as (
    select * from {{ ref('int_product_margins') }}
),

enriched as (
    select
        i.order_item_id,
        i.order_id,
        i.product_id,
        i.product_name,
        i.category_name,
        i.root_category,
        i.category_path,
        i.quantity,
        i.unit_price,
        i.line_total,
        m.cost,
        m.margin_pct,
        i.quantity * m.cost as line_cost,
        i.line_total - (i.quantity * m.cost) as line_margin
    from items i
    left join margins m on i.product_id = m.product_id
)

select * from enriched
