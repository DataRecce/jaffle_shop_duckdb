with customer_360 as (
    select * from {{ ref('customer_360') }}
),

summary as (
    select
        count(*) as total_customers,
        count(case when number_of_orders > 0 then 1 end) as active_customers,
        avg(customer_lifetime_value) as avg_clv,
        avg(number_of_orders) as avg_orders_per_customer,
        count(case when customer_segment = 'Champion' then 1 end) as champion_customers,
        count(case when customer_segment = 'At Risk' then 1 end) as at_risk_customers,
        count(case when customer_segment = 'Lost' then 1 end) as lost_customers,
        avg(review_count) as avg_reviews_per_customer
    from customer_360
)

select * from summary
