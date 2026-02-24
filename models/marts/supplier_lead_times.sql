with supply as (
    select * from {{ ref('int_supply_order_costs') }}
),

lead_times as (
    select
        product_id,
        product_name,
        store_id,
        count(*) as order_count,
        avg(lead_time_days) as avg_lead_time,
        min(lead_time_days) as min_lead_time,
        max(lead_time_days) as max_lead_time,
        sum(quantity) as total_quantity,
        sum(total_cost) as total_spend
    from supply
    group by product_id, product_name, store_id
)

select * from lead_times
