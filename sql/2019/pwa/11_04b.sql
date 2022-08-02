# standardSQL
# 11_04b: Manifests that are not JSON parsable
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
    round(
        count(distinct page)
        * 100
        / sum(count(distinct page)) over (partition by client),
        2
    ) as pct
from `httparchive.almanac.manifests`
where date = '2019-07-01'
group by client, can_parse
order by freq desc
