# standardSQL
# Number of H2 and H3 Pushed Resources and Bytes by Content type
select
    percentile,
    client,
    type,
    count(distinct page) as num_pages,
    approx_quantiles(num_requests, 1000) [offset (percentile * 10)] as pushed_requests,
    approx_quantiles(kib_transfered, 1000) [offset (percentile * 10)] as kib_transfered
from
    (
        select
            client,
            page,
            type,
            sum(respsize / 1024) as kib_transfered,
            count(0) as num_requests
        from `httparchive.almanac.requests`
        where
            date = '2021-07-01' and pushed = '1' and (
                lower(protocol) = 'http/2' or lower(
                    protocol
                ) like '%quic%' or lower(protocol) like 'h3%' or lower(
                    protocol
                ) = 'http/3'
            )
        group by client, page, type
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client, type
order by percentile, client
