# standardSQL
# 10_16: <h1> length
select
    percentile,
    client,
    approx_quantiles(length(h1), 1000) [offset (percentile * 10)] as h1_length
from
    (
        select client, regexp_extract(body, '(?i)<h1>([^(</h1>)]*)</h1>') as h1
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
