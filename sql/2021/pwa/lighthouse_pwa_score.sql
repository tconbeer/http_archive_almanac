# standardSQL
# Percentiles of lighthouse pwa score
# This metric comes from Lighthouse only and is only available in mobile in HTTP
# Archive dataset
select
    '2021_07_01' as date,
    'PWA Sites' as type,
    percentile,
    approx_quantiles(score, 1000) [offset (percentile * 10)] * 100 as score
from
    (
        select
            url,
            cast(json_extract(report, '$.categories.pwa.score') as numeric) as score
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
join
    (
        select url
        from `httparchive.pages.2021_07_01_mobile`
        where
            json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
            and json_extract(payload, '$._pwa.manifests') != '[]'
    )
    using(url),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by date, percentile
union all
select
    '2021_07_01' as date,
    'All Sites' as type,
    percentile,
    approx_quantiles(score, 1000) [offset (percentile * 10)] * 100 as score
from
    (
        select cast(json_extract(report, '$.categories.pwa.score') as numeric) as score
        from `httparchive.lighthouse.2021_07_01_mobile`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by date, percentile
order by date, type desc, percentile
