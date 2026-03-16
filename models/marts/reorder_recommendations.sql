with stock as (
    select * from {{ ref('product_inventory') }}
),

performance as (
    select * from {{ ref('product_performance') }}
),

recommendations as (
    select
        s.product_id,
        s.product_name,
        s.store_id,
        s.store_name,
        s.current_stock,
        s.stock_status,
        s.last_restock_date,
        p.total_quantity_sold,
        p.times_ordered,
        case
            when s.stock_status = 'out_of_stock' then 'urgent'
            when s.stock_status = 'low_stock' then 'soon'
            when s.stock_status = 'adequate' and p.times_ordered > 5 then 'monitor'
            else 'ok'
        end as reorder_priority,
        greatest(50 - s.current_stock, 0) as suggested_reorder_qty
    from stock s
    left join performance p on s.product_id = p.product_id
)

select * from recommendations
