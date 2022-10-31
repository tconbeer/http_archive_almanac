# standardSQL
# Structured data formats
# returns all the data we need from _wpt_bodies
create temporary function getstructureddatawptbodies(wpt_bodies_string string)
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
    safe_divide(count(0), sum(count(0)) over (partition by client)) as pct

from
    (
        select
            _table_suffix as client,
            total,
            getstructureddatawptbodies(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as structured_data_wpt_bodies_info
        from `httparchive.pages.2021_07_01_*`
        join
            (
                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`
                group by _table_suffix
            ) using (_table_suffix)
    ),
    unnest(structured_data_wpt_bodies_info.items_by_format) as format
group by total, format, client
order by count desc
