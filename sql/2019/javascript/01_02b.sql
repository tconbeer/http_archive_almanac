# standardSQL
# 01_02b: Distribution of 1P/3P JS bytes by client
select
    percentile,
    client,
    round(
        approx_quantiles(first_party, 1000) [offset (percentile * 10)], 2
    ) as first_party_js_kbytes,
    round(
        approx_quantiles(third_party, 1000) [offset (percentile * 10)], 2
    ) as third_party_js_kbytes
from
    (
        select
            client,
            sum(if(net.host(page) = net.host(url), respsize, 0) / 1024) as first_party,
            sum(if(net.host(page) != net.host(url), respsize, 0) / 1024) as third_party
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01' and type = 'script'
        group by client, page
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
