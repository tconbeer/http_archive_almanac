# standardSQL
# 14_02: AMP plugin version
select
    client,
    amp_plugin_version,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client,
            url,
            regexp_extract(
                body,
                '(?i)<meta[^>]+name=[\'"]?generator[^>]+content=[\'"]?AMP Plugin v(\\d+\\.\\d+[^\'">]*)'
            ) as amp_plugin_version
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
join
    (
        select _table_suffix as client, url
        from `httparchive.technologies.2019_07_01_*`
        where app = 'WordPress'
    )
    using
    (client, url)
group by client, amp_plugin_version
