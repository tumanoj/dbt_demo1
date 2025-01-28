-- This model combines customer segmentation and activity status

WITH segmented_customers AS (
    SELECT
        CUSTOMER_ID,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        STATUS,
        TOTAL_SPEND,
        SEGMENT,
        CUSTOMER_SEGMENT
    FROM {{ ref('customer_segmented') }}
),

activity_status AS (
    SELECT
        CUSTOMER_ID,
        ACTIVITY_STATUS
    FROM {{ ref('customer_activity_status') }}
)

SELECT
    s.CUSTOMER_ID,
    s.FIRST_NAME,
    s.LAST_NAME,
    s.EMAIL,
    s.STATUS,
    s.TOTAL_SPEND,
    s.CUSTOMER_SEGMENT,
    a.ACTIVITY_STATUS
FROM segmented_customers s
LEFT JOIN activity_status a
    ON s.CUSTOMER_ID = a.CUSTOMER_ID
