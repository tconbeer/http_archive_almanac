# standardSQL
# distribution_of_compression_types_by_cdn.sql : What compression formats are being
# used (gzip, brotli, etc) for compressed resources served by CDNs
select
    client,
    cdn,
    compression_type,
    count(0) as num_requests,
    sum(count(0)) over (partition by client, cdn) as total_compressed,
    count(0) / sum(count(0)) over (partition by client, cdn) as pct
from
    (
        select
            client,
            ifnull(
                nullif(regexp_extract(_cdn_provider, r'^([^,]*).*'), ''), 'ORIGIN'
            ) as cdn,  # sometimes _cdn provider detection includes multiple entries. we bias for the DNS detected entry which is the first entry
            case
                when resp_content_encoding = 'gzip'
                then 'Gzip'
                when resp_content_encoding = 'br'
                then 'Brotli'
                when resp_content_encoding = ''
                then 'no text compression'
                else 'other'
            end as compression_type
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and resp_content_encoding != ''
    )
group by client, cdn, compression_type
order by client, cdn, compression_type
