with revenue as (
    select * from {{ ref('revenue_summary') }}
),

stores as (
    select * from {{ ref('stores') }}
),

daily as (
    select
        r.order_date,
        r.store_id,
        s.store_name,
        s.city,
        r.order_count,
        r.revenue,
        r.cost,
        r.margin,
        r.discounts,
        r.net_revenue
    from revenue r
    left join stores s on r.store_id = s.store_id
)

select * from daily
