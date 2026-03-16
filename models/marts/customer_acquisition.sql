with first_last as (
    select * from {{ ref('int_customer_first_last_orders') }}
),

orders as (
    select * from {{ ref('int_order_enriched') }}
),

first_order_details as (
    select
        fl.customer_id,
        fl.first_order_date,
        o.has_promotion as acquired_via_promotion,
        o.promotion_name as acquisition_promotion,
        o.subtotal as first_order_value,
        o.item_count as first_order_items,
        date_trunc('month', fl.first_order_date) as acquisition_month
    from first_last fl
    inner join orders o on fl.customer_id = o.customer_id
        and fl.first_order_date = o.order_date
)

select * from first_order_details
