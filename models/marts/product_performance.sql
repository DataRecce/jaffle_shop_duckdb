with products as (
    select * from {{ ref('products') }}
),

items as (
    select
        product_id,
        count(*) as times_ordered,
        sum(quantity) as total_quantity_sold,
        sum(line_total) as total_revenue,
        sum(line_margin) as total_margin
    from {{ ref('order_items') }}
    group by product_id
),

ratings as (
    select * from {{ ref('int_product_ratings') }}
),

performance as (
    select
        p.product_id,
        p.product_name,
        p.category_name,
        p.root_category,
        p.price,
        p.cost,
        p.margin_pct,
        coalesce(i.times_ordered, 0) as times_ordered,
        coalesce(i.total_quantity_sold, 0) as total_quantity_sold,
        coalesce(i.total_revenue, 0) as total_revenue,
        coalesce(i.total_margin, 0) as total_margin,
        r.review_count,
        r.avg_rating,
        r.positive_reviews,
        r.negative_reviews
    from products p
    left join items i on p.product_id = i.product_id
    left join ratings r on p.product_id = r.product_id
)

select * from performance
