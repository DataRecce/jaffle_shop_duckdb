with source as (
    select * from {{ ref('raw_supply_orders') }}
),

renamed as (
    select
        id as supply_order_id,
        product_id,
        store_id,
        quantity,
        cast(order_date as date) as order_date,
        cast(delivered_date as date) as delivered_date
    from source
)

select * from renamed
