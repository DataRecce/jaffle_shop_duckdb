with source as (
    select * from {{ ref('raw_promotions') }}
),

renamed as (
    select
        id as promotion_id,
        name as promotion_name,
        discount_type,
        cast(discount_value as decimal) as discount_value,
        cast(start_date as date) as start_date,
        cast(end_date as date) as end_date
    from source
)

select * from renamed
