with employees as (
    select * from {{ ref('stg_employees') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

store_staff as (
    select
        s.store_id,
        s.store_name,
        s.city,
        s.state,
        count(*) as total_employees,
        sum(case when e.role = 'manager' then 1 else 0 end) as manager_count,
        sum(case when e.role = 'barista' then 1 else 0 end) as barista_count,
        sum(case when e.role = 'cashier' then 1 else 0 end) as cashier_count,
        sum(case when e.role = 'cook' then 1 else 0 end) as cook_count,
        min(e.hired_at) as earliest_hire,
        max(e.hired_at) as latest_hire
    from stores s
    left join employees e on s.store_id = e.store_id
    group by s.store_id, s.store_name, s.city, s.state
)

select * from store_staff
