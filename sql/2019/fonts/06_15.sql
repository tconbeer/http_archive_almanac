# standardSQL
# 06_15: % of pages preconnecting a web font host
create temporary function getpreconnecturls(payload string)
returns array
< string
> language js
as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['link-nodes'].filter(link => link.rel == 'preconnect').map(link => link.href);
} catch (e) {
  return [];
}
'''
;

select
    client,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    (
        select _table_suffix as client, url as page, payload
        from `httparchive.pages.2019_07_01_*`
    )
join
    (
        select client, page, url
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and type = 'font'
    ) using (client, page)
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client),
    unnest(getpreconnecturls(payload)) as preconnect_url
where
    # hosts match
    net.host(preconnect_url) = net.host(url)
    # protocols match
    and substr(preconnect_url, 0, 5) = substr(url, 0, 5)
group by client, total
