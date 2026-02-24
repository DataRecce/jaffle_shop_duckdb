with inventory as (
    select * from {{ ref('product_inventory') }}
),

movements as (
    select
        product_id,
        store_id,
        sum(quantity_in) as total_inbound,
        sum(quantity_out) as total_outbound,
        count(case when movement_type = 'supply' then 1 end) as restock_events,
        count(case when movement_type = 'sale' then 1 end) as sale_events
    from {{ ref('int_inventory_movements') }}
    group by product_id, store_id
),

health as (
    select
        i.product_store_key,
        i.product_id,
        i.product_name,
        i.store_id,
        i.store_name,
        i.current_stock,
        i.stock_status,
        m.total_inbound,
        m.total_outbound,
        m.restock_events,
        m.sale_events,
        case
            when m.total_outbound > m.total_inbound then 'deficit'
            when i.current_stock > m.total_outbound * 2 then 'overstocked'
            else 'balanced'
        end as inventory_balance,
        case when m.sale_events > 0
            then round(cast(m.total_outbound as decimal) / m.sale_events, 1)
            else 0
        end as avg_units_per_sale
    from inventory i
    left join movements m on i.product_id = m.product_id and i.store_id = m.store_id
)

select * from health
