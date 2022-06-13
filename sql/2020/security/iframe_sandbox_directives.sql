# standardSQL
# usage of different directives for sandbox attribute on iframes
create temp function getnumwithsandboxattribute(payload string) as (
    (
        select count(0)
        from
            unnest(
                json_extract_array(
                    json_extract_scalar(payload, '$._security'),
                    '$.iframe-allow-sandbox'
                )
            ) as iframeattr
        where json_extract_scalar(iframeattr, '$.sandbox') is not null
    )
)
;

select
    client,
    trim(sandbox_attr) as directive,
    total_iframes_with_sandbox,
    count(0) as freq,
    count(0) / total_iframes_with_sandbox as pct
from
    (
        select
            _table_suffix as client,
            json_extract_array(
                json_extract_scalar(payload, '$._security'), '$.iframe-allow-sandbox'
            ) as iframeattrs
        from `httparchive.pages.2020_08_01_*`
    ),
    unnest(iframeattrs) as iframeattr,
    unnest(split(json_extract_scalar(iframeattr, '$.sandbox'), ' ')) as sandbox_attr
join
    (
        select
            _table_suffix as client,
            sum(getnumwithsandboxattribute(payload)) as total_iframes_with_sandbox
        from `httparchive.pages.2020_08_01_*`
        group by client
    ) using(client)
group by client, directive, total_iframes_with_sandbox
order by client, pct desc
