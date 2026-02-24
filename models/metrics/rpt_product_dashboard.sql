with performance as (
    select * from {{ ref('product_performance') }}
),

summary as (
    select
        count(*) as total_products,
        sum(total_revenue) as total_product_revenue,
        avg(avg_rating) as overall_avg_rating,
        sum(total_quantity_sold) as total_units_sold,
        count(case when times_ordered = 0 then 1 end) as never_ordered_products,
        max(total_revenue) as top_product_revenue,
        first(product_name order by total_revenue desc) as top_product_name
    from performance
)

select * from summary
