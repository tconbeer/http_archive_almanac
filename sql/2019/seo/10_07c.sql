# standardSQL
# 10_07c: <meta description> length
create temp function getmetadescriptionlength(payload string)
returns int64 language js
as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  var description = almanac['meta-nodes'].find(meta => meta.name.toLowerCase() == 'description');
  return description && description.content.length;
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    approx_quantiles(description_length, 1000)[offset(percentile * 10)] as desc_length
from
    (
        select
            _table_suffix as client,
            getmetadescriptionlength(payload) as description_length
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
