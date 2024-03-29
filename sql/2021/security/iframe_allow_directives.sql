# standardSQL
# usage of different directives for allow attribute on iframes
create temp function getnumwithallowattribute(payload string)
as
    (
        (
            select count(0)
            from
                unnest(
                    json_extract_array(
                        json_extract_scalar(payload, '$._security'),
                        '$.iframe-allow-sandbox'
                    )
                ) as iframeattr
            where json_extract_scalar(iframeattr, '$.allow') is not null
        )
    )
;

select
    client,
    split(trim(allow_attr), ' ')[offset(0)] as directive,
    total_iframes_with_allow,
    count(0) as freq,
    count(0) / total_iframes_with_allow as pct
from
    (
        select
            _table_suffix as client,
            json_extract_array(
                json_extract_scalar(payload, '$._security'), '$.iframe-allow-sandbox'
            ) as iframeattrs
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest(iframeattrs) as iframeattr,
    unnest(
        regexp_extract_all(json_extract_scalar(iframeattr, '$.allow'), r'(?i)([^,;]+)')
    ) as allow_attr
join
    (
        select
            _table_suffix as client,
            sum(getnumwithallowattribute(payload)) as total_iframes_with_allow
        from `httparchive.pages.2021_07_01_*`
        group by client
    ) using (client)
group by client, directive, total_iframes_with_allow
having pct > 0.001
order by client, pct desc
