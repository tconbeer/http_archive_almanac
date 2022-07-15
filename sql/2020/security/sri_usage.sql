# standardSQL
# Subresource integrity: number of pages that use SRI (per tagname), and tagname usage
# for all SRI elements
select
    client,
    countif(sri is not null) as total_sris,
    count(distinct url) as total_urls,
    count(distinct if(sri is not null, url, null)) as freq,
    count(distinct if(sri is not null, url, null)) / count(distinct url) as pct,
    countif(json_extract_scalar(sri, '$.tagname') = 'script') as freq_script_sris,
    countif(json_extract_scalar(sri, '$.tagname') = 'script')
    / countif(sri is not null) as pct_script_sris,
    countif(json_extract_scalar(sri, '$.tagname') = 'link') as freq_link_sris,
    countif(json_extract_scalar(sri, '$.tagname') = 'link')
    / countif(sri is not null) as pct_link_sris,
    count(
        distinct if(json_extract_scalar(sri, '$.tagname') = 'script', url, null)
    ) as freq_script_urls,
    count(distinct if(json_extract_scalar(sri, '$.tagname') = 'script', url, null))
    / count(distinct url) as pct_script_urls,
    count(
        distinct if(json_extract_scalar(sri, '$.tagname') = 'link', url, null)
    ) as freq_link_urls,
    count(distinct if(json_extract_scalar(sri, '$.tagname') = 'link', url, null))
    / count(distinct url) as pct_link_urls
from
    (
        select
            _table_suffix as client,
            url,
            json_extract_array(
                json_extract_scalar(payload, '$._security'), '$.sri-integrity'
            ) as sris
        from `httparchive.pages.2020_08_01_*`
    )
left join unnest(sris) as sri
group by client
order by client, pct desc
