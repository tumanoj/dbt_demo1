SELECT 
    ID AS PAYMENT_ID,
    ORDERID,
    PAYMENTMETHOD,
    STATUS,
    AMOUNT,
    CREATED
FROM stellar-concord-448718-m1.gcs_to_gbq_cust_ds.gcs_to_gbq_payments