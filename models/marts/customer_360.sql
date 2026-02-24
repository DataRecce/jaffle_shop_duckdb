with customers as (
    select * from {{ ref('customers') }}
),

clv as (
    select * from {{ ref('customer_lifetime_value') }}
),

first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

enriched_orders as (
    select * from {{ ref('int_order_enriched') }}
),

retention as (
    select
        fl.customer_id,
        max(
            (date_part('year', o.order_date) - date_part('year', fl.first_order_date)) * 12
            + date_part('month', o.order_date) - date_part('month', fl.first_order_date)
        ) as months_active
    from first_last fl
    inner join enriched_orders o on fl.customer_id = o.customer_id
    group by fl.customer_id
),

reviews as (
    select * from {{ ref('int_customer_review_activity') }}
),

segments as (
    select * from {{ ref('customer_segments_final') }}
),

unified as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.first_order,
        c.most_recent_order,
        c.number_of_orders,
        c.customer_lifetime_value,
        clv.monthly_value,
        clv.avg_order_value,
        clv.customer_tenure_days,
        clv.days_since_last_order,
        s.customer_segment,
        s.rfm_total,
        coalesce(r.review_count, 0) as review_count,
        r.avg_rating as avg_review_rating,
        coalesce(ret.months_active, 0) as months_active
    from customers c
    left join clv on c.customer_id = clv.customer_id
    left join segments s on c.customer_id = s.customer_id
    left join reviews r on c.customer_id = r.customer_id
    left join retention ret on c.customer_id = ret.customer_id
)

select * from unified
