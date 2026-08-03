# standardSQL
# assetlink usage
select
    'PWA sites' as type,
    _table_suffix as client,
    count(0) as freq,
    total,
    count(0) / total as pct
from `httparchive.pages.2021_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where
            json_extract(payload, '$._pwa.manifests') != '[]'
            and json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix
    ) using (_table_suffix)
where
    json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
    and json_extract(payload, '$._pwa.manifests') != '[]'
    and json_extract_scalar(
        json_value(payload, '$._well-known'), "$['/.well-known/assetlinks.json'].found"
    )
    = 'true'
group by client, total
union all
select
    'All sites' as type,
    _table_suffix as client,
    count(0) as freq,
    total,
    count(0) / total as pct
from `httparchive.pages.2021_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where
    json_extract_scalar(
        json_value(payload, '$._well-known'), "$['/.well-known/assetlinks.json'].found"
    )
    = 'true'
group by client, total
order by type desc, freq / total desc, client
