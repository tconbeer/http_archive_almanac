# standardSQL
# Number of H2 and H3 Pushed Resources and bytes transferred
select
    percentile,
    client,
    http_version,
    count(distinct page) as num_pages,
    approx_quantiles(num_requests, 1000) [offset (percentile * 10)] as pushed_requests,
    approx_quantiles(kb_transfered, 1000) [offset (percentile * 10)] as kb_transfered
from
    (
        select
            client,
            page,
            json_extract_scalar(payload, '$._protocol') as http_version,
            sum(
                cast(json_extract_scalar(payload, '$._bytesIn') as int64) / 1024
            ) as kb_transfered,
            count(0) as num_requests
        from `httparchive.almanac.requests`
        where
            date = '2020-08-01' and json_extract_scalar(
                payload, '$._was_pushed'
            ) = '1' and (
                lower(
                    json_extract_scalar(payload, '$._protocol')
                ) like 'http/2' or lower(
                    json_extract_scalar(payload, '$._protocol')
                ) like '%quic%' or lower(
                    json_extract_scalar(payload, '$._protocol')
                ) like 'h3%' or lower(
                    json_extract_scalar(payload, '$._protocol')
                ) like 'http/3%'
            )
        group by client, http_version, page
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client, http_version
order by percentile, client
