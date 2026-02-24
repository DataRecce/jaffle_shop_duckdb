with source as (
    select * from {{ ref('raw_categories') }}
),

renamed as (
    select
        id as category_id,
        name as category_name,
        case when parent_category_id = '' then null
             else cast(parent_category_id as integer)
        end as parent_category_id
    from source
)

select * from renamed
