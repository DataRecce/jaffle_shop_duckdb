with orders as (
    select * from {{ ref('stg_orders') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

assigned as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        ((o.order_id - 1) % (select count(*) from stores)) + 1 as store_id
    from orders o
)

select * from assigned
