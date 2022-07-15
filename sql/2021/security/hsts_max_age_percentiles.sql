# standardSQL
# Distribution of max-age value of Strict-Transport-Security header
select
    client,
    percentile,
    approx_quantiles(max_age, 1000 ignore nulls) [offset (percentile * 10)] as max_age
from
    (
        select
            client,
            safe_cast(
                regexp_extract(
                    regexp_extract(
                        respotherheaders, r'(?i)strict-transport-security =([^,]+)'
                    ),
                    r'(?i)max-age=\s*(-?\d+)'
                ) as numeric
            ) as max_age
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
