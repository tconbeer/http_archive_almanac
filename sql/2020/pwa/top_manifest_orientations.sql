# standardSQL
# Top manifest orientations - based on 2019/14_04g.sql
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
    lower(getorientation(body)) as orientation,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select distinct client, body
        from `httparchive.almanac.manifests`
        where date = '2020-08-01'
    )
group by client, orientation
having orientation is not null
order by freq / total desc, orientation, client
