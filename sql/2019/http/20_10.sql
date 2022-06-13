# standardSQL
# 20.10 - Count of HTTP/2 Sites using HTTP/2 Push
select client, count(distinct page) as num_pages
from
    (

        select client, page
        from `httparchive.almanac.requests`
        where
            date = '2019-07-01' and json_extract_scalar(
                payload, '$._protocol'
            ) = 'HTTP/2' and json_extract_scalar(payload, '$._was_pushed') = '1'
    )
group by client
