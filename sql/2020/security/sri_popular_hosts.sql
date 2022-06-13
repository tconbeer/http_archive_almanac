# standardSQL
# Subresource integrity: most popular hosts for which SRI is used on script tags
select
    client,
    net.host(json_extract_scalar(sri, '$.src')) as host,
    sum(count(0)) over (partition by client) as total_sri_scripts,
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by client) as pct,
    sum(count(distinct url)) over (partition by client) as total_urls,
    count(distinct url) as freq_urls,
    count(distinct url) / sum(
        count(distinct url)
    ) over (partition by client) as pct_urls
from
    (
        select
            _table_suffix as client,
            url,
            json_extract_array(
                json_extract_scalar(payload, '$._security'), '$.sri-integrity'
            ) as sris
        from `httparchive.pages.2020_08_01_*`
    ),
    unnest(sris) as sri
where sri is not null and json_extract_scalar(sri, '$.tagname') = 'script'
group by client, host
order by pct desc
