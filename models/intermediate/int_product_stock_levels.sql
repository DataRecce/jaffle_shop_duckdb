{{
    config(
        materialized='incremental',
        unique_key='product_store_key'
    )
}}

with movements as (
    select * from {{ ref('int_inventory_movements') }}
),

stock as (
    select
        product_id || '-' || store_id as product_store_key,
        product_id,
        store_id,
        sum(quantity_in) as total_received,
        sum(quantity_out) as total_sold,
        sum(quantity_in) - sum(quantity_out) as current_stock,
        max(case when movement_type = 'supply' then movement_date end) as last_restock_date,
        max(case when movement_type = 'sale' then movement_date end) as last_sale_date
    from movements

    {% if is_incremental() %}
    where movement_date > (select max(coalesce(last_restock_date, last_sale_date)) from {{ this }})
    {% endif %}

    group by product_id, store_id
)

select * from stock
