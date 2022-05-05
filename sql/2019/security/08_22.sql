# standardSQL
# 08_22: HSTS - variance in max-age
select
    percentile,
    client,
    approx_quantiles(max_age, 1000) [offset (percentile * 10)] as max_age
from
    (
        select
            _table_suffix as client,
            cast(
                regexp_extract(
                    regexp_extract(
                        respotherheaders, r'(?i)\W?strict-transport-security =([^,]+)'
                    ),
                    r'(?i)max-age= *-?(\d+)'
                ) as int64
            ) as max_age
        from `httparchive.summary_requests.2019_07_01_*`
        where firsthtml
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
where max_age is not null
group by percentile, client
order by percentile, client
