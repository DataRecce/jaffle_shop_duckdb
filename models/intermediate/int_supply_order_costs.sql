with supply_orders as (
    select * from {{ ref('stg_supply_orders') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

costed as (
    select
        so.supply_order_id,
        so.product_id,
        p.product_name,
        so.store_id,
        so.quantity,
        p.cost as unit_cost,
        so.quantity * p.cost as total_cost,
        so.order_date,
        so.delivered_date,
        so.delivered_date - so.order_date as lead_time_days
    from supply_orders so
    left join products p on so.product_id = p.product_id
)

select * from costed
