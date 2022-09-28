# standardSQL
# page almanac favicon image types grouped by device and type
# returns all the data we need from _almanac
create temporary function getfaviconimage(almanac_string string)
returns struct
< image_type_extension string
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
    favicon.image_type_extension as image_type_extension,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            _table_suffix as client,
            getfaviconimage(json_extract_scalar(payload, '$._almanac')) as favicon
        from `httparchive.pages.2021_07_01_*`
    )
group by client, image_type_extension
order by pct desc, client, freq desc
limit 1000
