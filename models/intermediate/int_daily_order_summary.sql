{{
    config(
        materialized='incremental',
        unique_key='order_date'
    )
}}

with orders as (
    select * from {{ ref('int_order_enriched') }}
),

daily as (
    select
        order_date,
        count(*) as order_count,
        count(distinct customer_id) as unique_customers,
        sum(subtotal) as total_revenue,
        sum(total_cost) as total_cost,
        sum(total_margin) as total_margin,
        sum(total_quantity) as total_items_sold,
        sum(case when has_promotion then 1 else 0 end) as promoted_orders,
        sum(discount_amount) as total_discounts,
        avg(subtotal) as avg_order_value
    from orders

    {% if is_incremental() %}
    where order_date > (select max(order_date) from {{ this }})
    {% endif %}

    group by order_date
)

select * from daily
