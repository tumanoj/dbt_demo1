-- create a summary model to calculate the overall percent gain per symbol, across all
-- seasons

select
    symbol,
    sum(shares) as total_shares,
    avg(percent_gain) as avg_percent_gain,
    sum(start_value_usd) as total_start_value_usd,
    sum(end_value_usd) as total_end_value_usd
from {{ ref("stg_stock_data") }}
group by
    symbol

    -- This table provides a summary of the performance of each symbol, aggregating
    -- the data over all seasons.
    
