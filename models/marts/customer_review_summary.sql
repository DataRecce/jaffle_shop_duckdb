with reviews as (
    select * from {{ ref('int_customer_review_activity') }}
),

ratings as (
    select * from {{ ref('int_product_ratings') }}
),

summary as (
    select
        r.customer_id,
        r.review_count,
        r.avg_rating as customer_avg_rating,
        r.products_reviewed,
        r.first_review_date,
        r.last_review_date,
        avg(pr.avg_rating) as avg_product_rating_of_reviewed,
        case when r.avg_rating > avg(pr.avg_rating) then 'above_average'
             when r.avg_rating < avg(pr.avg_rating) then 'below_average'
             else 'average'
        end as rating_tendency
    from reviews r
    left join {{ ref('stg_reviews') }} sr on r.customer_id = sr.customer_id
    left join ratings pr on sr.product_id = pr.product_id
    group by r.customer_id, r.review_count, r.avg_rating, r.products_reviewed,
             r.first_review_date, r.last_review_date
)

select * from summary
