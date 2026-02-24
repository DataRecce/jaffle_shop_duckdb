with products as (
    select * from {{ ref('stg_products') }}
),

categories as (
    select * from {{ ref('int_category_hierarchy') }}
),

joined as (
    select
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        c.root_category,
        c.full_path as category_path,
        c.depth as category_depth,
        p.price,
        p.cost,
        p.created_at
    from products p
    left join categories c on p.category_id = c.category_id
)

select * from joined
