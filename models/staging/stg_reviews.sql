with source as (
    select * from {{ ref('raw_reviews') }}
),

renamed as (
    select
        id as review_id,
        order_id,
        product_id,
        customer_id,
        rating,
        cast(review_date as date) as review_date
    from source
)

select * from renamed
