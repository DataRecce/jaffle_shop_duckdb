with staff as (
    select * from {{ ref('int_store_employees_active') }}
),

final as (
    select
        store_id,
        store_name,
        city,
        state,
        total_employees,
        manager_count,
        barista_count,
        cashier_count,
        cook_count,
        earliest_hire,
        latest_hire
    from staff
)

select * from final
