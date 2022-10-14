# standardSQL
# Top manifest categories - based on 2019/14_04d.sql
CREATE TEMPORARY FUNCTION getCategories(manifest STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
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
''';

select
    client,
    normalize_and_casefold(category) as category,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select distinct client, body
        from `httparchive.almanac.manifests`
        where date = '2020-08-01'
    ),
    unnest(getcategories(body)) as category
group by client, category
having category is not null
order by freq / total desc, category, client
