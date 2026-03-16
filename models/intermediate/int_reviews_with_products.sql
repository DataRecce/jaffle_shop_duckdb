with reviews as (
    select * from {{ ref('stg_reviews') }}
),

products as (
    select * from {{ ref('int_products_with_categories') }}
),

enriched as (
    select
        r.review_id,
        r.order_id,
        r.product_id,
        p.product_name,
        p.category_name,
        p.root_category,
        r.customer_id,
        r.rating,
        r.review_date
    from reviews r
    left join products p on r.product_id = p.product_id
)

select * from enriched
