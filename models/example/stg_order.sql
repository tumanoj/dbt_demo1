SELECT 
    ID as ORDER_ID,
    USER_ID as CUSTOMER_ID,
    ORDER_DATE,
    STATUS,
    ORDER_START_TIME,
    ORDER_DURATION_MIN
FROM stellar-concord-448718-m1.gcs_to_gbq_cust_ds.gcs_to_gbq_orders
ORDER BY ID DESC