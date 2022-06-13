# standardSQL
# 11_04d: Top manifest categories
create temporary function getcategories(manifest string)
returns array
< string
> language js
as '''
try {
  var $ = JSON.parse(manifest);
  var categories = $.categories;
  if (typeof categories == 'string') {
    return [categories];
  }
  return categories;
} catch (e) {
  return null;
}
'''
;

select
    client,
    normalize_and_casefold(category) as category,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.manifests`, unnest(getcategories(body)) as category
where date = '2019-07-01'
group by client, category
having category is not null
order by freq / total desc
