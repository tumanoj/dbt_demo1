-- This model identifies active vs inactive customers

WITH customer_activity AS (
    SELECT
        CUSTOMER_ID,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        STATUS,
        LAST_ACTIVITY_DATE,
        CASE
            WHEN LAST_ACTIVITY_DATE > CURRENT_DATE - INTERVAL 30 DAY THEN 'Active'
            ELSE 'Inactive'
        END AS ACTIVITY_STATUS
    FROM {{ ref('stg_customer') }}
)

SELECT * FROM customer_activity
