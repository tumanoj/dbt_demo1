--create a model that calculates the performance metrics for each season. 
--This helps track how each symbol performed within different time periods.

WITH seasonal_performance AS (
    SELECT
        season,
        symbol,
        rank,
        SUM(shares) AS total_shares,
        AVG(percent_gain) AS avg_percent_gain,
        SUM(start_value_usd) AS total_start_value_usd,
        SUM(end_value_usd) AS total_end_value_usd
    FROM {{ ref('stg_stock_data') }}
    GROUP BY season, symbol, rank
)
SELECT * FROM seasonal_performance

--This model will give insights into performance per season, considering rank and symbol.