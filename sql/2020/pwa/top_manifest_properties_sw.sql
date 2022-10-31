# standardSQL
# Top 500 manifest properties - based on 2019/14_04.sql
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
    count(distinct page) / total as pct
from
    (
        select
            client,
            page,
            getmanifestprops(m.body) as properties,
            count(distinct m.page) over (partition by client) as total
        from `httparchive.almanac.manifests`
        join `httparchive.almanac.service_workers` using (date, client, page)
        where date = '2020-08-01'
    ),
    unnest(properties) as property
group by client, total, property
having freq > 10
order by freq / total desc, property, client
