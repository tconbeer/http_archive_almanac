# standardSQL
# 11_04f: Top manifest icon sizes
create temporary function geticonsizes(manifest string)
returns array<string>
language js
as '''
try {
  var $ = JSON.parse(manifest);
  return $.icons.map(icon => icon.sizes);
} catch (e) {
  return null;
}
'''
;

select
    client,
    size,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.manifests`, unnest(geticonsizes(body)) as size
where date = '2019-07-01'
group by client, size
having size is not null
order by freq / total desc
