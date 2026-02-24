with source as (
    select * from {{ ref('raw_employees') }}
),

renamed as (
    select
        id as employee_id,
        store_id,
        first_name,
        last_name,
        role,
        cast(hired_at as date) as hired_at
    from source
)

select * from renamed
