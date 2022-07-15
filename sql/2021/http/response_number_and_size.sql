# standardSQL
# Number and Size of all responses by percentile
select
    client,
    percentile,
    approx_quantiles(number, 1000) [offset (percentile * 10)] as responsescount,
    approx_quantiles(
        respheadersizekib, 1000) [offset (percentile * 10)
    ] as respheadersizekib,
    approx_quantiles(
        respbodysizekib, 1000) [offset (percentile * 10)
    ] as respbodysizekib
from
    (
        select
            client,
            page,
            count(0) as number,
            sum(respheaderssize) / 1024 as respheadersizekib,
            sum(respbodysize) / 1024 as respbodysizekib
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
        group by client, page
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by client, percentile
order by client, percentile
