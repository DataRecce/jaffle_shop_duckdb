SELECT
       order_id, 
       ROUND(amount) AS rounded_amount_dollar,
       amount_cent,
       (ROUND(amount) * 100 - amount_cent) AS rounding_difference_cents
FROM {{ ref('stg_payments') }}
