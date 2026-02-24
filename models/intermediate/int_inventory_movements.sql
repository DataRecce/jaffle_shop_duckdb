with supply_in as (
    select
        product_id,
        store_id,
        delivered_date as movement_date,
        quantity as quantity_in,
        0 as quantity_out,
        'supply' as movement_type
    from {{ ref('stg_supply_orders') }}
),

order_items as (
    select * from {{ ref('int_order_items_with_products') }}
),

store_assignments as (
    select * from {{ ref('int_store_order_assignments') }}
),

sales_out as (
    select
        oi.product_id,
        sa.store_id,
        sa.order_date as movement_date,
        0 as quantity_in,
        oi.quantity as quantity_out,
        'sale' as movement_type
    from order_items oi
    inner join store_assignments sa on oi.order_id = sa.order_id
),

combined as (
    select * from supply_in
    union all
    select * from sales_out
)

select * from combined
