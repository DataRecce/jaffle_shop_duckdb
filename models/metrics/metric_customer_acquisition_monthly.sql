with cohorts as (
    select * from {{ ref('customer_cohorts') }}
),

final as (
    select
        cohort_month,
        cohort_size as new_customers,
        avg_lifetime_orders,
        avg_tenure_days,
        sum(cohort_size) over (order by cohort_month) as cumulative_customers
    from cohorts
)

select * from final
