with reviews as (
    select * from {{ ref('stg_reviews') }}
),

customer_reviews as (
    select
        customer_id,
        count(*) as review_count,
        avg(rating) as avg_rating,
        min(rating) as min_rating,
        max(rating) as max_rating,
        min(review_date) as first_review_date,
        max(review_date) as last_review_date,
        count(distinct product_id) as products_reviewed
    from reviews
    group by customer_id
)

select * from customer_reviews
