# standardSQL
# 11_04: Top 500 manifest properties
create temporary function getmanifestprops(manifest string)
returns array<string>
language js
as '''
try {
  return Object.keys(JSON.parse(manifest));
} catch (e) {
  return null;
}
'''
;

select
    client,
    property,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    (
        select
            client,
            page,
            getmanifestprops(body) as properties,
            count(distinct page) over (partition by client) as total
        from `httparchive.almanac.manifests`
        where date = '2019-07-01'
    ),
    unnest(properties) as property
group by client, total, property
order by freq / total desc
limit 500
