-- This model calculates cohort retention based on last activity date

WITH cohorts AS (
    SELECT
        CUSTOMER_ID,
        COHORT_MONTH,
        COHORT_YEAR,
        COHORT_MONTH_NUM
    FROM {{ ref('stg_cohorts') }}
),

activity AS (
    SELECT
        CUSTOMER_ID,
        LAST_ACTIVITY_DATE,
        DATE_TRUNC(LAST_ACTIVITY_DATE, MONTH) AS ACTIVITY_MONTH
    FROM {{ ref('stg_customer') }}
)

SELECT
    c.COHORT_YEAR,
    c.COHORT_MONTH,
    c.COHORT_MONTH_NUM,
    a.ACTIVITY_MONTH,
    COUNT(DISTINCT a.CUSTOMER_ID) AS ACTIVE_USERS
FROM cohorts c
JOIN activity a ON c.CUSTOMER_ID = a.CUSTOMER_ID
WHERE a.ACTIVITY_MONTH >= c.COHORT_MONTH
GROUP BY c.COHORT_YEAR, c.COHORT_MONTH, c.COHORT_MONTH_NUM, a.ACTIVITY_MONTH
ORDER BY c.COHORT_YEAR, c.COHORT_MONTH, a.ACTIVITY_MONTH
