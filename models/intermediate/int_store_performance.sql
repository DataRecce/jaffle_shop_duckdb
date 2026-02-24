with revenue as (
    select * from {{ ref('int_store_revenue') }}
),

staff as (
    select * from {{ ref('int_store_employees_active') }}
),

performance as (
    select
        s.store_id,
        s.store_name,
        s.city,
        s.state,
        s.total_employees,
        r.order_count,
        r.unique_customers,
        r.total_revenue,
        r.total_margin,
        r.avg_order_value,
        case when s.total_employees > 0
            then round(r.total_revenue / s.total_employees, 2)
            else 0
        end as revenue_per_employee,
        case when s.total_employees > 0
            then round(cast(r.order_count as decimal) / s.total_employees, 1)
            else 0
        end as orders_per_employee
    from staff s
    left join revenue r on s.store_id = r.store_id
)

select * from performance
