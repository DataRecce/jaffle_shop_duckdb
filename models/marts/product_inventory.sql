with stock as (
    select * from {{ ref('int_product_stock_levels') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

final as (
    select
        s.product_store_key,
        s.product_id,
        p.product_name,
        s.store_id,
        st.store_name,
        s.total_received,
        s.total_sold,
        s.current_stock,
        s.last_restock_date,
        s.last_sale_date,
        case
            when s.current_stock <= 0 then 'out_of_stock'
            when s.current_stock < 10 then 'low_stock'
            when s.current_stock < 50 then 'adequate'
            else 'well_stocked'
        end as stock_status
    from stock s
    left join products p on s.product_id = p.product_id
    left join stores st on s.store_id = st.store_id
)

select * from final
