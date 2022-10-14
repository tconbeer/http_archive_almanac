# standardSQL
# usage of different directives for sandbox attribute on iframes
CREATE TEMP FUNCTION getNumWithSandboxAttribute(payload STRING) AS ((
  SELECT
    COUNT(0)
  FROM
    UNNEST(JSON_EXTRACT_ARRAY(JSON_EXTRACT_SCALAR(payload, '$._security'), '$.iframe-allow-sandbox')) AS iframeAttr
  WHERE
    JSON_EXTRACT_SCALAR(iframeAttr, '$.sandbox') IS NOT NULL
));

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
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest(iframeattrs) as iframeattr,
    unnest(split(json_extract_scalar(iframeattr, '$.sandbox'), ' ')) as sandbox_attr
join
    (
        select
            _table_suffix as client,
            sum(getnumwithsandboxattribute(payload)) as total_iframes_with_sandbox
        from `httparchive.pages.2021_07_01_*`
        group by client
    ) using (client)
group by client, directive, total_iframes_with_sandbox
order by client, pct desc
