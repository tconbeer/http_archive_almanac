# standardSQL
# Measure number of TCP Connections per site.
select
    percentile,
    client,
    http_version_category,
    count(0) as num_pages,
    approx_quantiles(_connections, 1000)[offset(percentile * 10)] as connections
from
    (
        select
            client,
            page,
            case
                when lower(protocol) = 'quic' or lower(protocol) like 'h3%'
                then 'HTTP/2+'
                when lower(protocol) = 'http/2' or lower(protocol) = 'http/3'
                then 'HTTP/2+'
                when protocol is null
                then 'Unknown'
                else upper(protocol)
            end as http_version_category
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and firsthtml
    )
join
    (
        select _table_suffix as client, url as page, _connections
        from `httparchive.summary_pages.2021_07_01_*`
    )
    using
    (client, page),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client, http_version_category
order by percentile, client, num_pages desc, http_version_category
