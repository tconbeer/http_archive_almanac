# standardSQL
# 20.12 - Average number of HTTP/2 Pushed Resources and Average Bytes by Content type
select
    client,
    content_type,
    count(distinct page) as num_pages,
    round(avg(num_requests), 2) as avg_pushed_requests,
    round(avg(kb_transfered), 2) as avg_kb_transfered
from
    (

        select
            client,
            page,
            json_extract_scalar(payload, '$._contentType') as content_type,
            sum(
                cast(json_extract_scalar(payload, '$._bytesIn') as int64) / 1024
            ) as kb_transfered,
            count(0) as num_requests
        from `httparchive.almanac.requests`
        where
            date = '2019-07-01' and json_extract_scalar(
                payload, '$._protocol'
            ) = 'HTTP/2' and json_extract_scalar(payload, '$._was_pushed') = '1'
        group by client, page, content_type
    )
group by client, content_type
