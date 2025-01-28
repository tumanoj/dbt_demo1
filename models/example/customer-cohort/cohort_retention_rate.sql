-- This model calculates cohort retention rates

WITH cohort_data AS (
    SELECT
        c.COHORT_YEAR,
        c.COHORT_MONTH,
        c.COHORT_MONTH_NUM,
        COUNT(DISTINCT c.CUSTOMER_ID) AS TOTAL_USERS
    FROM {{ ref('stg_cohorts') }} c
    GROUP BY c.COHORT_YEAR, c.COHORT_MONTH, c.COHORT_MONTH_NUM
),

retention_data AS (
    SELECT
        c.COHORT_YEAR,
        c.COHORT_MONTH,
        c.COHORT_MONTH_NUM,
        --a.ACTIVITY_MONTH,
        DATE_TRUNC(a.LAST_ACTIVITY_DATE, MONTH) AS ACTIVITY_MONTH,
        COUNT(DISTINCT a.CUSTOMER_ID) AS ACTIVE_USERS
    FROM {{ ref('stg_cohorts') }} c
    JOIN {{ ref('stg_customer') }} a ON c.CUSTOMER_ID = a.CUSTOMER_ID
    WHERE a.LAST_ACTIVITY_DATE >= c.COHORT_MONTH
    GROUP BY c.COHORT_YEAR, c.COHORT_MONTH, c.COHORT_MONTH_NUM , a.LAST_ACTIVITY_DATE
)

SELECT
    r.COHORT_YEAR,
    r.COHORT_MONTH,
    r.ACTIVITY_MONTH,
    r.ACTIVE_USERS,
    c.TOTAL_USERS,
    (r.ACTIVE_USERS / c.TOTAL_USERS) * 100 AS RETENTION_RATE
FROM retention_data r
JOIN cohort_data c
    ON r.COHORT_YEAR = c.COHORT_YEAR
    AND r.COHORT_MONTH = c.COHORT_MONTH
ORDER BY r.COHORT_YEAR, r.COHORT_MONTH, r.ACTIVITY_MONTH