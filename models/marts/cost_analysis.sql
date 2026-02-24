with supply_costs as (
    select
        product_id,
        product_name,
        count(*) as supply_order_count,
        sum(quantity) as total_units_ordered,
        sum(total_cost) as total_supply_spend,
        avg(unit_cost) as avg_unit_cost,
        avg(lead_time_days) as avg_lead_time
    from {{ ref('int_supply_order_costs') }}
    group by product_id, product_name
),

product_prof as (
    select * from {{ ref('product_profitability') }}
),

analysis as (
    select
        pp.product_id,
        pp.product_name,
        pp.category_name,
        pp.total_revenue,
        pp.gross_margin,
        sc.total_supply_spend,
        sc.avg_unit_cost,
        sc.avg_lead_time,
        sc.supply_order_count,
        pp.total_quantity_sold,
        case when pp.total_quantity_sold > 0
            then round(sc.total_supply_spend / pp.total_quantity_sold, 2)
            else 0
        end as supply_cost_per_unit_sold
    from product_prof pp
    left join supply_costs sc on pp.product_id = sc.product_id
)

select * from analysis
