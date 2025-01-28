--create a summary model to calculate the overall percent gain per symbol, across all seasons
WITH symbol_summary AS (
    SELECT
        symbol,
        SUM(shares) AS total_shares,
        AVG(percent_gain) AS avg_percent_gain,
        SUM(start_value_usd) AS total_start_value_usd,
        SUM(end_value_usd) AS total_end_value_usd
    FROM {{ ref('stg_stock_data') }}
    GROUP BY symbol
)
SELECT * FROM symbol_summary

--This table provides a summary of the performance of each symbol, aggregating the data over all seasons.