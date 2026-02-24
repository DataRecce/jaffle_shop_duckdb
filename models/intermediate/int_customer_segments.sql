with order_history as (
    select * from {{ ref('int_customer_order_history') }}
),

first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

rfm as (
    select
        oh.customer_id,
        oh.first_name,
        oh.last_name,
        oh.total_orders,
        oh.total_spent,
        fl.days_since_last_order,
        ntile(5) over (order by fl.days_since_last_order desc) as recency_score,
        ntile(5) over (order by oh.total_orders) as frequency_score,
        ntile(5) over (order by oh.total_spent) as monetary_score
    from order_history oh
    inner join first_last fl on oh.customer_id = fl.customer_id
    where oh.total_orders > 0
),

segmented as (
    select
        *,
        recency_score + frequency_score + monetary_score as rfm_total,
        case
            when recency_score >= 4 and frequency_score >= 4 and monetary_score >= 4 then 'Champion'
            when recency_score >= 4 and frequency_score >= 3 then 'Loyal'
            when recency_score >= 4 and frequency_score <= 2 then 'New Customer'
            when recency_score <= 2 and frequency_score >= 3 then 'At Risk'
            when recency_score <= 2 and frequency_score <= 2 and monetary_score >= 3 then 'Cant Lose'
            when recency_score <= 2 then 'Lost'
            else 'Potential'
        end as customer_segment
    from rfm
)

select * from segmented
