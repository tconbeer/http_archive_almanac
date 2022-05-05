# standardSQL
# 08_42: % pages with Clear-Site-Data header
select
    client,
    countif(regexp_contains(respotherheaders, '(?i)clear-site-data =')) as freq,
    count(0) as total,
    round(
        countif(
            regexp_contains(respotherheaders, '(?i)clear-site-data =')
        ) * 100 / count(0),
        2
    ) as pct
from `httparchive.almanac.summary_response_bodies`
where date = '2019-07-01' and firsthtml
group by client
