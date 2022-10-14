# standardSQL
# Measure of all HTTP versions (0.9, 1.0, 1.1, 2, QUIC) for main page of all sites,
# and for HTTPS sites. Table for last crawl.
select
    client,
    case
        when lower(protocol) = 'quic' or lower(protocol) like 'h3%'
        then 'HTTP/2+'
        when lower(protocol) = 'http/2' or lower(protocol) = 'http/3'
        then 'HTTP/2+'
        when protocol is null
        then 'Unknown'
        else upper(protocol)
    end as http_version_category,
    count(0) as num_pages,
    sum(count(0)) over (partition by client) as total,
    countif(url like 'https://%') as num_https_pages,
    count(0) / sum(count(0)) over (partition by client) as pct_pages,
    countif(url like 'https://%')
    / sum(count(0)) over (partition by client) as pct_https_pages
from `httparchive.almanac.requests`
where date = '2021-07-01' and firsthtml
group by client, http_version_category
order by pct_pages desc
