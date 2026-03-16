with employees as (
    select * from {{ ref('stg_employees') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

staffing as (
    select
        e.employee_id,
        e.first_name,
        e.last_name,
        e.role,
        e.hired_at,
        e.store_id,
        s.store_name,
        s.city,
        s.state
    from employees e
    left join stores s on e.store_id = s.store_id
)

select * from staffing
