# standardSQL
# compression_format_trend.sql : What compression formats are being used (gzip,
# brotli, etc)
select
    extract(year from date) as year,
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
    count(0) as num_requests
from
    (
        select date, client, resp_content_encoding
        from `httparchive.almanac.requests`
        where date in ('2021-07-01', '2020-08-01', '2019-07-01')
    )

group by year, client, compression_type
order by compression_type desc
