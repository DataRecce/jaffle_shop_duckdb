with performance as (
    select * from {{ ref('product_performance') }}
),

supply_costs as (
    select
        product_id,
        sum(total_cost) as total_supply_cost,
        sum(quantity) as total_supplied
    from {{ ref('int_supply_order_costs') }}
    group by product_id
),

profitability as (
    select
        p.product_id,
        p.product_name,
        p.category_name,
        p.total_revenue,
        p.total_margin as gross_margin,
        coalesce(sc.total_supply_cost, 0) as total_supply_cost,
        p.total_revenue - coalesce(sc.total_supply_cost, 0) as net_margin,
        case when p.total_revenue > 0
            then round(p.total_margin / p.total_revenue * 100, 1)
            else 0
        end as gross_margin_pct,
        p.total_quantity_sold,
        coalesce(sc.total_supplied, 0) as total_supplied,
        p.avg_rating
    from performance p
    left join supply_costs sc on p.product_id = sc.product_id
)

select * from profitability
