# standardSQL
# most common hostnames of iframes that have the allow or sandbox attribute
create temp function haspolicy(attr string, policy_type string)
returns bool deterministic
language js
as '''
  const $ = JSON.parse(attr);
  return $[policy_type] !== null;
'''
;

select
    client,
    policy_type,
    hostname,
    total_iframes,
    countif(has_policy) as freq,
    countif(has_policy) / total_iframes as pct
from
    (
        select
            client,
            policy_type,
            json_extract_scalar(iframeattr, '$.hostname') as hostname,
            haspolicy(iframeattr, policy_type) as has_policy
        from
            (
                select
                    _table_suffix as client,
                    json_extract_array(
                        json_extract_scalar(payload, '$._security'),
                        '$.iframe-allow-sandbox'
                    ) as iframeattrs
                from `httparchive.pages.2021_07_01_*`
            ),
            unnest(iframeattrs) as iframeattr,
            unnest( ['allow', 'sandbox']) as policy_type
    )
join
    (
        select
            _table_suffix as client,
            sum(
                array_length(
                    json_extract_array(
                        json_extract_scalar(payload, '$._security'),
                        '$.iframe-allow-sandbox'
                    )
                )
            ) as total_iframes
        from `httparchive.pages.2021_07_01_*`
        group by client
    )
    using
    (client)
group by client, total_iframes, policy_type, hostname
having pct > 0.001
order by client, pct desc
