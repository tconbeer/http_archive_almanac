# standardSQL
# 20.2 - Measure of all HTTP versions (0.9, 1.0, 1.1, 2, QUIC) for main page of all
# sites, and for HTTPS sites. Table for last crawl.
select
    client,
    json_extract_scalar(payload, '$._protocol') as protocol,
    count(0) as num_pages,
    sum(count(0)) over (partition by client) as total,
    countif(url like 'https://%') as num_https_pages,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct_pages,
    round(
        countif(url like 'https://%') * 100 / sum(count(0)) over (partition by client),
        2
    ) as pct_https
from `httparchive.almanac.requests`
where date = '2019-07-01' and firsthtml
group by client, protocol
order by num_pages / total desc
