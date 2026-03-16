with source as (
    select * from {{ ref('raw_order_items') }}
),

renamed as (
    select
        id as order_item_id,
        order_id,
        product_id,
        quantity,
        cast(unit_price as decimal) / 100 as unit_price
    from source
)

select * from renamed
