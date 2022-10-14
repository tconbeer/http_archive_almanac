# standardSQL
# Counting Manifests and Service Workers
select
    client,
    safe_divide(
        sum(serviceworker), sum(count(0)) over (partition by client)
    ) as serviceworkers,
    safe_divide(sum(manifests), sum(count(0)) over (partition by client)) as manifests,
    safe_divide(
        countif(serviceworker > 0 or manifests > 0),
        sum(count(0)) over (partition by client)
    ) as either,
    safe_divide(
        countif(serviceworker > 0 and manifests > 0),
        sum(count(0)) over (partition by client)
    ) as both,
    sum(count(0)) over (partition by client) as total
from
    (
        select
            _table_suffix as client,
            if(
                json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true', 1, 0
            ) as serviceworker,
            if(json_extract(payload, '$._pwa.manifests') != '[]', 1, 0) as manifests
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
