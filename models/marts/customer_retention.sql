with first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

orders as (
    select * from {{ ref('int_order_enriched') }}
),

cohort_orders as (
    select
        fl.customer_id,
        date_trunc('month', fl.first_order_date) as cohort_month,
        date_trunc('month', o.order_date) as order_month,
        (date_part('year', o.order_date) - date_part('year', fl.first_order_date)) * 12
            + date_part('month', o.order_date) - date_part('month', fl.first_order_date) as months_since_first
    from first_last fl
    inner join orders o on fl.customer_id = o.customer_id
),

retention as (
    select
        cohort_month,
        months_since_first,
        count(distinct customer_id) as customers
    from cohort_orders
    group by cohort_month, months_since_first
)

select * from retention
