# standardSQL
# Percent of pages using Performance observer
select
    client,
    num_urls as pages_with_performance_observer,
    total_urls as total_pages,
    pct_urls as pct_pages_with_performance_observer
from `httparchive.blink_features.usage`
where yyyymmdd = '20200801' and feature = 'PerformanceObserverForWindow'
