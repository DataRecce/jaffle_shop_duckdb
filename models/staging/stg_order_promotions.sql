with source as (
    select * from {{ ref('raw_order_promotions') }}
),

renamed as (
    select
        order_id,
        promotion_id
    from source
)

select * from renamed
