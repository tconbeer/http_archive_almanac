# standardSQL
# 11_04g: Top manifest orientations
CREATE TEMPORARY FUNCTION getOrientation(manifest STRING)
RETURNS STRING LANGUAGE js AS '''
try {
  var $ = JSON.parse(manifest);
  if (!('orientation' in $)) {
    return '(not set)';
  }
  return $.orientation;
} catch (e) {
  return null;
}
''';

select
    client,
    getorientation(body) as orientation,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.manifests`
where date = '2019-07-01'
group by client, orientation
having orientation is not null
order by freq / total desc
