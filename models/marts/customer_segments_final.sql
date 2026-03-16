with segments as (
    select * from {{ ref('int_customer_segments') }}
),

final as (
    select
        customer_id,
        first_name,
        last_name,
        customer_segment,
        recency_score,
        frequency_score,
        monetary_score,
        rfm_total,
        total_orders,
        total_spent,
        days_since_last_order
    from segments
)

select * from final
