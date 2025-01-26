-- Fetch last amount and transaction time
with customers as (
    select * from {{ref("stg_customer")}} 
),

orders as (
    select * from {{ref("stg_order")}} 
),

payments as (
    select * from {{ref("stg_payment")}} 
),

lagged_time AS (
    select 		
        payments.payment_id,
        payments.order_id,
        payments.amount,
        LAG(payments.amount) OVER (PARTITION BY payments.order_id ORDER BY payments.transaction_timestamp) AS previous_amount,
        lag(transaction_timestamp) over (PARTITION BY payments.order_id order by payments.transaction_timestamp) as last_transaction_time,
        transaction_timestamp,
        orders.status,
        customers.first_name
        from payments 
        left join orders using(order_id)
        left join customers using(customer_id)
        where payments.order_id in (101,102)
)
select * from lagged_time
