with inventory as (
    select * from {{ ref('product_inventory') }}
),

snapshot as (
    select
        current_date as snapshot_date,
        count(distinct product_id) as total_products_tracked,
        count(distinct store_id) as total_stores,
        sum(current_stock) as total_stock_units,
        sum(case when stock_status = 'out_of_stock' then 1 else 0 end) as out_of_stock_count,
        sum(case when stock_status = 'low_stock' then 1 else 0 end) as low_stock_count,
        sum(case when stock_status = 'adequate' then 1 else 0 end) as adequate_count,
        sum(case when stock_status = 'well_stocked' then 1 else 0 end) as well_stocked_count,
        round(avg(current_stock), 1) as avg_stock_per_product_store
    from inventory
)

select * from snapshot
