-- This model segments customers based on their total spend

WITH customer_data AS (
    SELECT
        CUSTOMER_ID,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        STATUS,
        TOTAL_SPEND,
        SEGMENT,
        CASE
            WHEN TOTAL_SPEND >= 1000 THEN 'High Value'
            WHEN TOTAL_SPEND >= 500 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS CUSTOMER_SEGMENT
    FROM {{ ref('stg_customer') }}
)

SELECT * FROM customer_data
