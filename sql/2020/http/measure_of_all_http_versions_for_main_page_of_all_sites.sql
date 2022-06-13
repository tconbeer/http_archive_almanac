# standardSQL
# Measure of all HTTP versions (0.9, 1.0, 1.1, 2, QUIC) for main page of all sites,
# and for HTTPS sites. Table for last crawl.
select
    client,
    json_extract_scalar(payload, '$._protocol') as protocol,
    count(0) as num_pages,
    sum(count(0)) over (partition by client) as total,
    countif(url like 'https://%') as num_https_pages,
    count(0) / sum(count(0)) over (partition by client) as pct_pages,
    countif(url like 'https://%') / sum(
        count(0)
    ) over (partition by client) as pct_https
from `httparchive.almanac.requests`
where date = '2020-08-01' and firsthtml
group by client, protocol
order by num_pages / total desc
