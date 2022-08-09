# standardSQL
# 08_33: Groupings of "cross-origin-opener-policy" values
select
    client,
    policy,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(
        regexp_extract_all(
            lower(respotherheaders), r'cross-origin-opener-policy = ([^,\r\n]+)'
        )
    ) as policy
where date = '2019-07-01' and firsthtml
group by client, policy
order by freq / total desc
