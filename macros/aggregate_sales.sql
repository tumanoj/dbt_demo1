-- macros/aggregate_sales.sql
{% macro aggregate_sales(table) %}
  select
    PAYMENT_ID,
    PAYMENTMETHOD,
    sum(AMOUNT) as TOTAL_SALES
  from {{ table }} 
  where STATUS='success'
  group by PAYMENT_ID, PAYMENTMETHOD
{% endmacro %}
