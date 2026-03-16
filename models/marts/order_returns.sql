with orders as (
    select * from {{ ref('orders') }}
),

returns as (
    select
        *,
        case
            when status in ('returned', 'Sreturned') then 'completed_return'
            when status in ('return_pending', 'Sreturn_pending') then 'pending_return'
        end as return_status
    from orders
    where status in ('returned', 'return_pending', 'Sreturned', 'Sreturn_pending')
)

select * from returns
