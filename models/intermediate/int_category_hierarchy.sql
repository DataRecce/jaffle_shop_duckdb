with recursive category_tree as (
    select
        category_id,
        category_name,
        parent_category_id,
        category_name as root_category,
        category_name as full_path,
        0 as depth
    from {{ ref('stg_categories') }}
    where parent_category_id is null

    union all

    select
        c.category_id,
        c.category_name,
        c.parent_category_id,
        ct.root_category,
        ct.full_path || ' > ' || c.category_name as full_path,
        ct.depth + 1 as depth
    from {{ ref('stg_categories') }} c
    inner join category_tree ct on c.parent_category_id = ct.category_id
)

select * from category_tree
