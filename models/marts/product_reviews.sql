with ratings as (
    select * from {{ ref('int_product_ratings') }}
),

final as (
    select
        product_id,
        product_name,
        category_name,
        root_category,
        review_count,
        avg_rating,
        positive_reviews,
        negative_reviews,
        case
            when avg_rating >= 4.5 then 'excellent'
            when avg_rating >= 3.5 then 'good'
            when avg_rating >= 2.5 then 'average'
            when avg_rating >= 1.5 then 'poor'
            else 'terrible'
        end as rating_tier,
        case when review_count > 0
            then round(cast(positive_reviews as decimal) / review_count * 100, 1)
            else 0
        end as positive_pct
    from ratings
)

select * from final
