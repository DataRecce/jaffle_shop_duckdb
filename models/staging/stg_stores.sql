with source as (
    select * from {{ ref('raw_stores') }}
),

renamed as (
    select
        id as store_id,
        name as store_name,
        city,
        state,
        cast(opened_at as date) as opened_at
    from source
)

select * from renamed
