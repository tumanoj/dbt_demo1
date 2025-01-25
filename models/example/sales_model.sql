-- models/sales_model.sql
{{ aggregate_sales(ref("stg_payment"))}}
