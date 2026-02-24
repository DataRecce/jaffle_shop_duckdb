with orders as (

    select * from {{ ref('stg_orders') }}

),

final as (

    select *
    from orders

)

select * from final
