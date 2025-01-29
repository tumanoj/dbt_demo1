-- create a model that calculates the performance metrics for each season. 
-- This helps track how each symbol performed within different time periods.
select
    season,
    symbol,
    rank,
    sum(shares) as total_shares,
    avg(percent_gain) as avg_percent_gain,
    sum(start_value_usd) as total_start_value_usd,
    sum(end_value_usd) as total_end_value_usd
from {{ ref("stg_stock_data") }}
group by
    season,
    symbol,
    rank

    -- This model will give insights into performance per season, considering rank and
    -- symbol.
    
