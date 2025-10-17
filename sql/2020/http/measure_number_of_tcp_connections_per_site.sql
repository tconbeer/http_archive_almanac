# standardSQL
# Measure number of TCP Connections per site.
select
    percentile,
    client,
    protocol,
    count(0) as num_pages,
    approx_quantiles(_connections, 1000)[offset(percentile * 10)] as connections
from
    (
        select client, page, json_extract_scalar(payload, '$._protocol') as protocol
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and firsthtml
    )
join
    (
        select _table_suffix as client, url as page, _connections
        from `httparchive.summary_pages.2020_08_01_*`
    ) using (client, page),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client, protocol
order by percentile, client, protocol
