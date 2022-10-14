# standardSQL
# pages markup metrics grouped by device and image loading attributes
# Note: this query only reports if an attribute was ever used on a page. It is not a
# per img report.
# helper to create percent fields
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

# returns all the data we need from _markup
CREATE TEMPORARY FUNCTION get_markup_info(markup_string STRING)
RETURNS STRUCT<
  loading ARRAY<STRING>
> LANGUAGE js AS '''
var result = {};

//Function to retrieve only keys if value is >0
function getKey(dict){
  const arr = [],
  obj = Object.keys(dict);
  for (var x in obj){
    if(dict[obj[x]] > 0){
      arr.push(obj[x]);
    }
  }
  return arr;
}

try {
    var markup = JSON.parse(markup_string);

    if (Array.isArray(markup) || typeof markup != 'object') return result;

    if (markup.images && markup.images.img && markup.images.img.loading) {
      result.loading = getKey(markup.images.img.loading);
    }
} catch (e) {}
return result;
''';

select
    client,
    loading,
    total,
    count(0) as count,
    as_percent(count(0), sum(count(0)) over (partition by client)) as pct
from
    (
        select
            _table_suffix as client,
            total,
            get_markup_info(json_extract_scalar(payload, '$._markup')) as markup_info
        from `httparchive.pages.2020_08_01_*`
        join
            (
                select _table_suffix, count(0) as total
                from `httparchive.pages.2020_08_01_*`
                group by _table_suffix
            # to get an accurate total of pages per device. also seems fast
            ) using (_table_suffix)
    ),
    unnest(markup_info.loading) as loading
group by total, loading, client
