SELECT
    ORDER_ID,
    ORDER_START_TIME, 
    ORDER_DURATION_MIN, 
    {{ get_end_time('ORDER_START_TIME', 'ORDER_DURATION_MIN') }} AS end_ORDER_END_TIME
FROM
    {{ref("stg_order")}} 
WHERE
    ORDER_ID IS NOT NULL 