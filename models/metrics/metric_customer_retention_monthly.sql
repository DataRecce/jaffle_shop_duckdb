with retention as (
    select * from {{ ref('customer_retention') }}
),

cohort_sizes as (
    select
        cohort_month,
        customers as cohort_size
    from retention
    where months_since_first = 0
),

rates as (
    select
        r.cohort_month,
        r.months_since_first,
        r.customers as retained_customers,
        cs.cohort_size,
        round(cast(r.customers as decimal) / cs.cohort_size * 100, 1) as retention_rate
    from retention r
    inner join cohort_sizes cs on r.cohort_month = cs.cohort_month
)

select * from rates
