# standardSQL
# page wpt_bodies metrics grouped by device and structured data format used on a page
# helper to create percent fields
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

# returns all the data we need from _wpt_bodies
create temporary function get_wpt_bodies_info(wpt_bodies_string string)
returns struct<items_by_format array<string>>
language js
as
    '''
var result = {
items_by_format: []
};

//Function to retrieve only keys if value is > 0
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
    var wpt_bodies = JSON.parse(wpt_bodies_string);

    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

    if (wpt_bodies.structured_data && wpt_bodies.structured_data.rendered && wpt_bodies.structured_data.rendered.items_by_format) {
        result.items_by_format = getKey(wpt_bodies.structured_data.rendered.items_by_format);
    }

} catch (e) {}
return result;
'''
;

select
    client,
    format,
    total,
    count(0) as count,
    as_percent(count(0), sum(count(0)) over (partition by client)) as pct

from
    (
        select
            _table_suffix as client,
            total,
            get_wpt_bodies_info(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as wpt_bodies_info
        from `httparchive.pages.2020_08_01_*`
        join
            (
                select _table_suffix, count(0) as total
                from `httparchive.pages.2020_08_01_*`
                group by _table_suffix
            )  # to get an accurate total of pages per device. also seems fast
            using (_table_suffix)
    ),
    unnest(wpt_bodies_info.items_by_format) as format
group by total, format, client
order by count desc
