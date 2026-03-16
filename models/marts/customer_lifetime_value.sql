with customers as (
    select * from {{ ref('customers') }}
),

first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

clv as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.number_of_orders,
        c.customer_lifetime_value as total_revenue,
        fl.first_order_date,
        fl.last_order_date,
        fl.customer_tenure_days,
        fl.days_since_last_order,
        case when fl.customer_tenure_days > 0
            then round(c.customer_lifetime_value / (fl.customer_tenure_days / 30.0), 2)
            else c.customer_lifetime_value
        end as monthly_value,
        case when c.number_of_orders > 0
            then round(c.customer_lifetime_value / c.number_of_orders, 2)
            else 0
        end as avg_order_value
    from customers c
    left join first_last fl on c.customer_id = fl.customer_id
)

select * from clv
