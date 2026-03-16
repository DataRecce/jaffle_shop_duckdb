  {{ config(materialized='table') }}
  
  with source as (
    
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_payments') }}

),

renamed as (

    select
        id as payment_id,
        order_id,
        CAST(payment_method as varchar(74)) as payment_method, -- Cast to varchar to ensure consistent data type

        -- `amount` is currently stored in cents, so we convert it to dollars
        amount / 100 as amount -- / 100 as amount

    from source
    where amount > 0 -- We only want to include payments with a positive amount

)

select * from renamed
