# standardSQL
# 19_14: Count of HTTP/2 Sites using HTTP/2 Push
select
    client,
    count(
        distinct if(json_extract_scalar(payload, '$._was_pushed') = '1', page, null)
    ) as num_pages,
    count(distinct page) as total,
    count(
        distinct if(json_extract_scalar(payload, '$._was_pushed') = '1', page, null)
    ) / count(distinct page) as pct
from `httparchive.almanac.requests`
where date = '2020-08-01' and json_extract_scalar(payload, '$._protocol') = 'HTTP/2'
group by client
