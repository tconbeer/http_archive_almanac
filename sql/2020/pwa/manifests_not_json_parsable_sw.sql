# standardSQL
# Manifests that are not JSON parsable for service worker pages - based on
# 2019/14_04b.sql
create temporary function canparsemanifest(manifest string)
returns boolean language js as '''
try {
  JSON.parse(manifest);
  return true;
} catch (e) {
  return false;
}
'''
;

select
    client,
    canparsemanifest(body) as can_parse,
    count(distinct page) as freq,
    sum(count(distinct page)) over (partition by client) as total,
    count(distinct page) / sum(count(distinct page)) over (partition by client) as pct
from
    (
        select distinct client, page, body
        from `httparchive.almanac.manifests`
        join `httparchive.almanac.service_workers` using(date, client, page)
        where date = '2020-08-01'
    )
group by client, can_parse
order by freq desc
