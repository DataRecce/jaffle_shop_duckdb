with orders as (
    select * from {{ ref('orders') }}
),

assignments as (
    select * from {{ ref('int_store_order_assignments') }}
),

staff as (
    select * from {{ ref('int_store_employees_active') }}
),

fulfillment as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        o.amount,
        a.store_id,
        s.store_name,
        s.city,
        s.state,
        s.total_employees as store_employee_count
    from orders o
    left join assignments a on o.order_id = a.order_id
    left join staff s on a.store_id = s.store_id
)

select * from fulfillment
