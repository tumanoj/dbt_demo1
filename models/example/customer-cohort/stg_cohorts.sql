-- This model generates cohorts based on customer join date (grouped by month)

WITH cohorts AS (
    SELECT
        CUSTOMER_ID,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        JOIN_DATE,
        DATE_TRUNC(JOIN_DATE, MONTH) AS COHORT_MONTH,  -- Group by month
        EXTRACT(YEAR FROM JOIN_DATE) AS COHORT_YEAR,   -- Extract year
        EXTRACT(MONTH FROM JOIN_DATE) AS COHORT_MONTH_NUM -- Extract month number
    FROM {{ ref('stg_customer') }}
)

SELECT * FROM cohorts
