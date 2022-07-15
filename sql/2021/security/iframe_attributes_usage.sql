# standardSQL
# usage of allow and sandbox attribute of iframe elements, per page and over all
# iframe elements
select
    client,
    count(0) as total_iframes,
    countif(allow is not null) as freq_allow,
    countif(allow is not null) / count(0) as pct_allow_frames,
    countif(sandbox is not null) as freq_sandbox,
    countif(sandbox is not null) / count(0) as pct_sandbox_frames,
    countif(allow is not null and sandbox is not null) as freq_both_frames,
    countif(allow is not null and sandbox is not null) / count(0) as pct_both_frames,
    count(distinct url) as total_urls,
    count(distinct if(allow is not null, url, null)) as allow_freq_urls,
    count(distinct if(allow is not null, url, null))
    / count(distinct url) as allow_pct_urls,
    count(distinct if(sandbox is not null, url, null)) as sandbox_freq_urls,
    count(distinct if(sandbox is not null, url, null))
    / count(distinct url) as sandbox_pct_urls
from
    (
        select
            client,
            url,
            json_extract_scalar(iframeattr, '$.allow') as allow,
            json_extract_scalar(iframeattr, '$.sandbox') as sandbox
        from
            (
                select
                    _table_suffix as client,
                    url,
                    json_extract_array(
                        json_extract_scalar(payload, '$._security'),
                        '$.iframe-allow-sandbox'
                    ) as iframeattrs
                from `httparchive.pages.2021_07_01_*`
            )
        left join unnest(iframeattrs) as iframeattr
    )
group by client
order by client
