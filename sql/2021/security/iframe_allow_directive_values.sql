# standardSQL
# distribution of values for different directives for allow attribute on iframes
CREATE TEMP FUNCTION getNumWithAllowAttribute(payload STRING) AS ((
  SELECT
    COUNT(0)
  FROM
    UNNEST(JSON_EXTRACT_ARRAY(JSON_EXTRACT_SCALAR(payload, '$._security'), '$.iframe-allow-sandbox')) AS iframeAttr
  WHERE
    JSON_EXTRACT_SCALAR(iframeAttr, '$.allow') IS NOT NULL
));

select
    client,
    split(trim(allow_attr), ' ')[offset(0)] as directive,
    trim(origin) as origin,
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
    ) using (client),
    unnest(  -- Directive may specify explicit origins or not.
        if(
            -- test if any explicit origin is provided
            array_length(split(trim(allow_attr), ' ')) = 1,
            -- if not, add a dummy empty origin to make the query work
            [trim(allow_attr), ''],
            split(trim(allow_attr), ' ')  -- if it is, split the different origins
        )
    ) as origin
with
offset as
offset
where
-- do not retain the first part of the directive (as this is the directive name)
offset > 0
group by client, directive, origin, total_iframes_with_allow
having pct > 0.001
order by client, pct desc
