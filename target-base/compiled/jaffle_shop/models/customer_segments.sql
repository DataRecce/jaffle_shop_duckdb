-- Customer Segmentation based on number of orders and lifetime value
SELECT
    customer_id,
    number_of_orders,
    customer_lifetime_value,
    CASE 
        WHEN number_of_orders > 10 THEN 'Frequent Buyer'
        WHEN number_of_orders BETWEEN 5 AND 10 THEN 'Occasional Buyer'
        ELSE 'Rare Buyer'
    END AS order_frequency_segment,
    CASE 
        WHEN customer_lifetime_value > 4000 THEN 'High Value'
        WHEN customer_lifetime_value BETWEEN 1500 AND 4000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment
FROM "jaffle_shop"."prod"."customers"