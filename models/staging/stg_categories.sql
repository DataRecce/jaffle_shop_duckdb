with source as (
    select * from {{ ref('raw_categories') }}
),

renamed as (
    select
        id as category_id,
        name as category_name,
        parent_category_id
    from source
)

select * from renamed
