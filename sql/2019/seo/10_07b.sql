# standardSQL
# 10_07b: <title> length
select
    percentile,
    client,
    approx_quantiles(length(title), 1000) [offset (percentile * 10)] as title_length
from
    (
        select
            client, regexp_extract(body, '(?i)<title>([^(</title>)]*)</title>') as title
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
