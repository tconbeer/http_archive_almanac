# standardSQL
# Number and size of status codes by percentile
select
    client,
    status_group,
    status,
    percentile,
    approx_quantiles(number, 1000) [offset (percentile * 10)] as number,
    approx_quantiles(respheadersizekib, 1000) [
        offset (percentile * 10)
    ] as respheadersizekib,
    approx_quantiles(respbodysizekib, 1000) [
        offset (percentile * 10)
    ] as respbodysizekib
from
    (
        select
            client,
            left(cast(status as string), 1) as status_group,
            status,
            page,
            count(0) as number,
            sum(respheaderssize) / 1024 as respheadersizekib,
            sum(respbodysize) / 1024 as respbodysizekib
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
        group by client, status, page
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by client, status_group, status, percentile
order by client, status, percentile
