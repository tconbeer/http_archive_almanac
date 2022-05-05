# standardSQL
# 14_02: AMP plugin mode
select
    client,
    amp_plugin_mode,
    count(distinct url) as freq,
    sum(count(distinct url)) over (partition by client) as total,
    round(
        count(distinct url) * 100 / sum(count(distinct url)) over (partition by client),
        2
    ) as pct
from
    (
        select
            client,
            page as url,
            split(
                regexp_extract(
                    body,
                    '(?i)<meta[^>]+name=[\'"]?generator[^>]+content=[\'"]?AMP Plugin v(\\d+\\.\\d+[^\'">]*)'
                ),
                ';'
            ) [safe_offset(1)] as amp_plugin_mode
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
inner join
    (
        select _table_suffix as client, url
        from `httparchive.technologies.2019_07_01_*`
        where app = 'WordPress'
    )
    using
    (client, url)
group by client, amp_plugin_mode
order by freq / total desc
