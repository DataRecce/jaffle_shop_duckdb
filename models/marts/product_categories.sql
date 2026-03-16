with hierarchy as (
    select * from {{ ref('int_category_hierarchy') }}
),

product_counts as (
    select
        category_id,
        count(*) as product_count
    from {{ ref('stg_products') }}
    group by category_id
),

final as (
    select
        h.category_id,
        h.category_name,
        h.parent_category_id,
        h.root_category,
        h.full_path,
        h.depth,
        coalesce(pc.product_count, 0) as product_count
    from hierarchy h
    left join product_counts pc on h.category_id = pc.category_id
)

select * from final
