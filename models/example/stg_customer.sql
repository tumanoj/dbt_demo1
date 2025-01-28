SELECT 
    ID as CUSTOMER_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE_NUMBER,
    DOB,
    JOIN_DATE,
    CITY,
    STATE,
    COUNTRY,
    STATUS,
    TOTAL_SPEND,
    LAST_ACTIVITY_DATE,
    SEGMENT,
    PREFERRED_CHANNEL
FROM stellar-concord-448718-m1.gcs_to_gbq_cust_ds.gcs_to_gbq_customers
ORDER BY ID 