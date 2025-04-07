
    
    

with all_values as (

    select
        value_segment as value_field,
        count(*) as n_records

    from "jaffle_shop"."prod"."customer_segments"
    group by value_segment

)

select *
from all_values
where value_field not in (
    'High Value','Medium Value','Low Value'
)


