# standardSQL
# Distribution of max-age values
select
    percentile,
    _table_suffix as client,
    approx_quantiles(cast(max_age as numeric), 1000) [
        offset (percentile * 10)
    ] as max_age
from
    (
        select
            _table_suffix,
            regexp_extract(resp_cache_control, r'(?i)max-age\s*=\s*(\d+)') as max_age
        from `httparchive.summary_requests.2021_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
where max_age is not null
group by percentile, client
order by percentile, client
