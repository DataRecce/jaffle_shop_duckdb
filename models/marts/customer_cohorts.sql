with first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

cohorts as (
    select
        date_trunc('month', first_order_date) as cohort_month,
        count(*) as cohort_size,
        avg(lifetime_orders) as avg_lifetime_orders,
        avg(customer_tenure_days) as avg_tenure_days
    from first_last
    group by date_trunc('month', first_order_date)
)

select * from cohorts
