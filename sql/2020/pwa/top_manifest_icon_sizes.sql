# standardSQL
# Top manifest icon sizes - based on 2019/14_04f.sql
create temporary function geticonsizes(manifest string)
returns array
< string
> language js
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
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select distinct client, body
        from `httparchive.almanac.manifests`
        where date = '2020-08-01'
    ),
    unnest(geticonsizes(body)) as size
group by client, size
having size is not null and freq > 100
order by freq / total desc, size, client
