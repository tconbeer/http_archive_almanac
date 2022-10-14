# standardSQL
# % manifests preferring native apps - based on 2019/14_04e.sql
CREATE TEMPORARY FUNCTION prefersNative(manifest STRING)
RETURNS BOOLEAN LANGUAGE js AS '''
try {
  var $ = JSON.parse(manifest);
  return $.prefer_related_applications == true && $.related_applications.length > 0;
} catch (e) {
  return null;
}
''';

select
    client,
    prefersnative(body) as prefers_native,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select distinct client, page, body
        from `httparchive.almanac.manifests`
        where date = '2020-08-01'
    )
group by client, prefers_native
having prefers_native is not null
order by client, prefers_native
