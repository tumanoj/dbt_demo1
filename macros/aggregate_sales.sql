-- macros/aggregate_sales.sql
{% macro aggregate_sales(table) %}
  select
    ORDER_ID,
    PAYMENT_ID,
    PAYMENTMETHOD,
    sum(AMOUNT) as TOTAL_SALES
  from {{ table }} 
  where STATUS='success'
  group by ORDER_ID,PAYMENT_ID, PAYMENTMETHOD
{% endmacro %}
