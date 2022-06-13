# standardSQL
# page almanac favicon image types grouped by device and type M217
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

# returns all the data we need from _almanac
create temporary function get_almanac_info(almanac_string string)
returns struct
<
image_type_extension string
> language js
as '''
var result = {};
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return result;

    if (almanac["link-nodes"] && almanac["link-nodes"].nodes && almanac["link-nodes"].nodes.find) {
      var faviconNode = almanac["link-nodes"].nodes.find(n => n.rel && n.rel.split(' ').find(r => r.trim().toLowerCase() == 'icon'));

      if (faviconNode) {
        if (faviconNode.href) {
          var temp = faviconNode.href;

          if (temp.includes('?')) {
            temp = temp.substring(0, temp.indexOf('?'));
          }

          if (temp.includes('.')) {
            temp = temp.substring(temp.lastIndexOf('.')+1);

            result.image_type_extension = temp.toLowerCase().trim();
          }
          else {
            result.image_type_extension = "NO_EXTENSION";
          }

        } else {
          result.image_type_extension = "NO_HREF";
        }
      } else {
        result.image_type_extension = "NO_ICON";
      }
    }
    else {
      result.image_type_extension = "NO_DATA";
    }

} catch (e) {result.image_type_extension = "NO_DATA";}
return result;
'''
;

select
    client,
    almanac_info.image_type_extension as image_type_extension,

    count(0) as freq,

    as_percent(count(0), sum(count(0)) over (partition by client)) as pct

from
    (
        select
            _table_suffix as client,
            get_almanac_info(json_extract_scalar(payload, '$._almanac')) as almanac_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client, image_type_extension
order by freq desc
limit 1000
