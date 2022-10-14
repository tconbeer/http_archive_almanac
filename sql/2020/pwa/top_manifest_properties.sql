# standardSQL
# Top 500 manifest properties - based on 2019/14_04.sql
CREATE TEMPORARY FUNCTION getManifestProps(manifest STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  return Object.keys(JSON.parse(manifest));
} catch (e) {
  return null;
}
''';

select
    client,
    property,
    count(distinct page) as freq,
    total,
    count(distinct page) / total as pct
from
    (
        select
            client,
            page,
            getmanifestprops(body) as properties,
            count(distinct page) over (partition by client) as total
        from `httparchive.almanac.manifests`
        where date = '2020-08-01'
    ),
    unnest(properties) as property
group by client, total, property
having freq > 10
order by freq / total desc, property, client
