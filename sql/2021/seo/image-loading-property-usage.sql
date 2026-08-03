# standardSQL
# Image loading property usage
# Note: This query only reports if an attribute was ever used on a page. It is not a
# per img report.
# returns all the data we need from _markup
create temporary function getloadingpropertymarkupinfo(markup_string string)
returns struct<loading array<string>>
language js
as '''
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
'''
;

select
    client,
    loading,
    total,
    count(0) as count,
    safe_divide(count(0), sum(count(0)) over (partition by client)) as pct
from
    (
        select
            _table_suffix as client,
            total,
            getloadingpropertymarkupinfo(
                json_extract_scalar(payload, '$._markup')
            ) as loading_property_markup_info
        from `httparchive.pages.2021_07_01_*`
        join
            (
                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`
                group by _table_suffix
            ) using (_table_suffix)
    ),
    unnest(loading_property_markup_info.loading) as loading
group by total, loading, client
