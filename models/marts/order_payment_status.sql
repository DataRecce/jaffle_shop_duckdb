with matched as (
    select * from {{ ref('int_order_payments_matched') }}
),

final as (
    select
        order_id,
        order_subtotal,
        total_paid,
        payment_count,
        payment_method_count,
        payment_status,
        coalesce(total_paid, 0) - coalesce(order_subtotal, 0) as payment_difference
    from matched
)

select * from final
