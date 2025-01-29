    SELECT 
        season,
        rank,
        symbol,
        shares,
        measurement_start,
        start_value_usd,
        measurement_end,
        end_value_usd,
        percent_gain
    FROM stellar-concord-448718-m1.gcs_to_gbq_cust_ds.gcs_to_gbq_stock_data

