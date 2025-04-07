with source as (
    select * from read_csv('jaffle-shop-data/raw_orders.csv', header = true, auto_detect = true)

),

renamed as (

    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status

    from source

)

select * from renamed