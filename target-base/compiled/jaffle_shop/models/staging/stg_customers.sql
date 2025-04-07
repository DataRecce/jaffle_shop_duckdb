with source as (
    select * from read_csv('jaffle-shop-data/raw_customers.csv', header = true, auto_detect = true)

),

renamed as (

    select
        id as customer_id,
        first_name,
        last_name

    from source

)

select * from renamed