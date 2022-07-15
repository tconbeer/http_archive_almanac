# standardSQL
# 01_04: Distribution of 1P/3P JS requests
select
    percentile,
    client,
    approx_quantiles(
        first_party, 1000) [offset (percentile * 10)
    ] as first_party_js_requests,
    approx_quantiles(
        third_party, 1000) [offset (percentile * 10)
    ] as third_party_js_requests
from
    (
        select
            client,
            countif(net.host(page) = net.host(url)) as first_party,
            countif(net.host(page) != net.host(url)) as third_party
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01' and type = 'script'
        group by client, page
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
