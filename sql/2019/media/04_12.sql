# standardSQL
# 04_12: Use of "Vary: User-Agent" or "Vary: Accept" on image responses
create temporary function getvary(payload string)
returns array
< string
> language js as '''
try {
  var $ = JSON.parse(payload);
  var header = $._headers.response.find(h => h.toLowerCase().startsWith('vary'));
  if (!header) {
    return null;
  }
  var value = header.substr(header.indexOf(':') + 1).trim();
  return value.split(',');
} catch (e) {
  return null;
}
'''
;

select
    client,
    countif(varies > 0) as pages,
    total,
    round(countif(varies > 0) * 100 / total, 2) as pct
from
    (
        select
            client,
            page,
            countif(regexp_contains(vary, '(?i)User-Agent|Accept')) as varies
        from `httparchive.almanac.requests`, unnest(getvary(payload)) as vary
        where date = '2019-07-01' and type = 'image'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
    using(client)
group by client, total
