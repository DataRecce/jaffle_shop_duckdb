with payments as (
    select
        order_id,
        sum(amount) as total_paid,
        count(*) as payment_count,
        count(distinct payment_method) as payment_method_count
    from {{ ref('stg_payments') }}
    group by order_id
),

order_totals as (
    select * from {{ ref('int_order_totals') }}
),

matched as (
    select
        coalesce(ot.order_id, p.order_id) as order_id,
        ot.subtotal as order_subtotal,
        p.total_paid,
        p.payment_count,
        p.payment_method_count,
        case
            when p.total_paid is null then 'unpaid'
            when abs(coalesce(ot.subtotal, 0) - p.total_paid) < 0.01 then 'matched'
            when p.total_paid < coalesce(ot.subtotal, 0) then 'underpaid'
            else 'overpaid'
        end as payment_status
    from order_totals ot
    full outer join payments p on ot.order_id = p.order_id
)

select * from matched
