# standardSQL
# pages markup metrics grouped by device and iframe loading attributes
# Note: this query only reports if an attribute was ever used on a page. It is not a
# per iframe report.
# helper to create percent fields
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

# returns all the data we need from _markup
create temporary function get_markup_info(markup_string string)
returns struct
< loading array
< string
> > language js as '''
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

    if (markup.iframes && markup.iframes.loading) {
      result.loading = getKey(markup.iframes.loading);
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
    sum(count(0)) over (partition by client) as device_count,
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
                # to get an accurate total of pages per device. also seems fast
                group by _table_suffix
            ) using (_table_suffix)
    ),
    unnest(markup_info.loading) as loading
group by total, loading, client
