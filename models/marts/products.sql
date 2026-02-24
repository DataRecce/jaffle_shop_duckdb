with products as (
    select * from {{ ref('int_products_with_categories') }}
),

margins as (
    select * from {{ ref('int_product_margins') }}
),

final as (
    select
        p.product_id,
        p.product_name,
        p.category_id,
        p.category_name,
        p.root_category,
        p.category_path,
        p.price,
        p.cost,
        m.margin,
        m.margin_pct,
        p.created_at
    from products p
    left join margins m on p.product_id = m.product_id
)

select * from final
