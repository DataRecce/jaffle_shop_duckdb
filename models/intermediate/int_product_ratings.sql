with reviews as (
    select * from {{ ref('int_reviews_with_products') }}
),

ratings as (
    select
        product_id,
        product_name,
        category_name,
        root_category,
        count(*) as review_count,
        round(avg(rating), 2) as avg_rating,
        sum(case when rating >= 4 then 1 else 0 end) as positive_reviews,
        sum(case when rating <= 2 then 1 else 0 end) as negative_reviews,
        min(rating) as min_rating,
        max(rating) as max_rating
    from reviews
    group by product_id, product_name, category_name, root_category
)

select * from ratings
