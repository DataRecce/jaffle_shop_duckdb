with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('int_products_with_categories') }}
),

joined as (
    select
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        p.product_name,
        p.category_name,
        p.root_category,
        p.category_path,
        oi.quantity,
        oi.unit_price,
        oi.quantity * oi.unit_price as line_total
    from order_items oi
    left join products p on oi.product_id = p.product_id
)

select * from joined
