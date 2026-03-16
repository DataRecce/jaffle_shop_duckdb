with products as (
    select * from {{ ref('stg_products') }}
),

margins as (
    select
        product_id,
        price,
        cost,
        price - cost as margin,
        case when price > 0
            then round((price - cost) / price * 100, 1)
            else 0
        end as margin_pct
    from products
)

select * from margins
