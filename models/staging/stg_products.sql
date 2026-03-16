with source as (
    select * from {{ ref('raw_products') }}
),

renamed as (
    select
        id as product_id,
        name as product_name,
        category_id,
        price as price_cents,
        cost as cost_cents,
        cast(price as decimal) / 100 as price,
        cast(cost as decimal) / 100 as cost,
        cast(created_at as date) as created_at
    from source
)

select * from renamed
