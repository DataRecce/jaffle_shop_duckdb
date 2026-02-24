with inventory as (
    select * from {{ ref('product_inventory') }}
),

store_level as (
    select
        store_id,
        store_name,
        count(distinct product_id) as unique_products,
        sum(current_stock) as total_stock_units,
        sum(case when stock_status = 'out_of_stock' then 1 else 0 end) as out_of_stock_products,
        sum(case when stock_status = 'low_stock' then 1 else 0 end) as low_stock_products,
        sum(case when stock_status = 'adequate' then 1 else 0 end) as adequate_stock_products,
        sum(case when stock_status = 'well_stocked' then 1 else 0 end) as well_stocked_products
    from inventory
    group by store_id, store_name
)

select * from store_level
