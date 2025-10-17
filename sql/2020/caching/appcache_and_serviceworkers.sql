# standardSQL
# Use of AppCache and ServiceWorkers
select
    if(starts_with(url, 'https'), 'https', 'http') as http_type,
    json_extract_scalar(report, '$.audits.appcache-manifest.score') as using_appcache,
    json_extract_scalar(
        report, '$.audits.service-worker.score'
    ) as using_serviceworkers,
    count(0) as occurrences,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from `httparchive.lighthouse.2020_08_01_mobile`
group by http_type, using_appcache, using_serviceworkers
order by pct desc
