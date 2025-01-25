-- macros/aggregate_sales.sql
{% macro aggregate_sales(table) %}
  select
    ORDERID as ORDER_ID,
    PAYMENT_ID,
    PAYMENTMETHOD,
    sum(AMOUNT) as TOTAL_SALES
  from {{ table }} 
  where STATUS='success'
  group by ORDERID,PAYMENT_ID, PAYMENTMETHOD
{% endmacro %}
