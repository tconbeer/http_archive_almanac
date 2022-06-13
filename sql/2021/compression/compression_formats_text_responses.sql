# standardSQL
# compression_formats_text_responses.sql : What compression formats are being used
# (gzip, brotli, etc) on text responses
select
    client,
    case
        when resp_content_encoding = 'gzip'
        then 'Gzip'
        when resp_content_encoding = 'br'
        then 'Brotli'
        when resp_content_encoding = ''
        then 'no text compression'
        else 'other'
    end as compression_type,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where
    date = '2021-07-01' and (
        resp_content_type like 'text/%'
        or resp_content_type like '%svg+xml%'
        or resp_content_type like '%ttf%'
        or resp_content_type like '%xml%'
        or resp_content_type like '%otf%'
        or resp_content_type in (
            'application/javascript', 'application/x-javascript', 'application/json'
        )
    )
group by client, compression_type
order by num_requests desc
