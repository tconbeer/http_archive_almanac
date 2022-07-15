# standardSQL
# Anchor rel attribute usage
# Note: this query only reports if a rel attribute value was ever used on a page. It
# is not a per anchor report.
create temporary function getrelstatswptbodies(wpt_bodies_string string)
returns struct
< rel array
< string
> > language js
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
    var wpt_bodies = JSON.parse(wpt_bodies_string);
    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;
    if (wpt_bodies.anchors && wpt_bodies.anchors.rendered && wpt_bodies.anchors.rendered.rel_attributes) {
      result.rel = getKey(wpt_bodies.anchors.rendered.rel_attributes);
    }
} catch (e) {}
return result;
'''
;

select client, rel, total, count(0) as count, safe_divide(count(0), total) as pct
from
    (
        select
            _table_suffix as client,
            total,
            getrelstatswptbodies(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as wpt_bodies_info
        from `httparchive.pages.2021_07_01_*`
        join
            (

                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`
                group by _table_suffix
            )
            using(_table_suffix)
    ),
    unnest(wpt_bodies_info.rel) as rel
group by total, rel, client
order by count desc, rel, client desc
