# standardSQL
# 11_04f: Top manifest icon sizes
CREATE TEMPORARY FUNCTION getIconSizes(manifest STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var $ = JSON.parse(manifest);
  return $.icons.map(icon => icon.sizes);
} catch (e) {
  return null;
}
''';

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
