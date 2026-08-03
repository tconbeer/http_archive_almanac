# standardSQL
# 20.15 - Measure number of TCP Connections per site.
select
    'mobile' as client,
    json_extract_scalar(payload, '$._protocol') as protocol,
    count(0) as num_pages,
    approx_quantiles(_connections, 100)[safe_ordinal(50)] as median,
    approx_quantiles(_connections, 100)[safe_ordinal(75)] as p75,
    approx_quantiles(_connections, 100)[safe_ordinal(95)] as p95
from `httparchive.requests.2019_07_01_mobile` as requests
inner join
    `httparchive.summary_pages.2019_07_01_mobile` as summary
    on requests.url = summary.url
where json_extract_scalar(payload, '$._is_base_page') = 'true'
group by client, protocol

union all

select
    'desktop' as client,
    json_extract_scalar(payload, '$._protocol') as protocol,
    count(0) as num_pages,
    approx_quantiles(_connections, 100)[safe_ordinal(50)] as median,
    approx_quantiles(_connections, 100)[safe_ordinal(75)] as p75,
    approx_quantiles(_connections, 100)[safe_ordinal(95)] as p95
from `httparchive.requests.2019_07_01_desktop` as requests
inner join
    `httparchive.summary_pages.2019_07_01_desktop` as summary
    on requests.url = summary.url
where json_extract_scalar(payload, '$._is_base_page') = 'true'
group by client, protocol
