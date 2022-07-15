# standardSQL
# Subresource integrity: most popular hosts for which SRI is used on script tags
with
    totals as (
        select _table_suffix as client, count(0) as total_sri_scripts
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                json_extract_array(
                    json_extract_scalar(payload, '$._security'), '$.sri-integrity'
                )
            ) as sri
        where sri is not null and json_extract_scalar(sri, '$.tagname') = 'script'
        group by client
    )

select
    client,
    net.host(json_extract_scalar(sri, '$.src')) as host,
    total_sri_scripts,
    count(0) as freq,
    count(0) / total_sri_scripts as pct,
    sum(count(distinct url)) over (partition by client) as total_urls,
    count(distinct url) as freq_urls,
    count(distinct url)
    / sum(count(distinct url)) over (partition by client) as pct_urls
from
    (
        select
            _table_suffix as client,
            url,
            json_extract_array(
                json_extract_scalar(payload, '$._security'), '$.sri-integrity'
            ) as sris
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest(sris) as sri
join totals using(client)
where sri is not null and json_extract_scalar(sri, '$.tagname') = 'script'
group by client, total_sri_scripts, host
order by pct desc
