# standardSQL
# meta open graph image types
# returns all the data we need from _almanac
CREATE TEMPORARY FUNCTION get_meta_og_image_types(almanac_string STRING)
RETURNS STRUCT<
  image_types ARRAY<STRING>
> LANGUAGE js AS '''
var result = {};
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return result;

    for (var node of almanac['meta-nodes']['nodes']) {
      if (node['property'] === 'og:image') {
        if (result.image_types == null)
          result.image_types = [];
        var url = node['content'];
        // parse image extension from url
        // https://www.example.com/filename.ext?param=1234#anchor
        // first group is for file name, second for extension and
        // third one for the remaining of the url
        var rex = new RegExp('([^/]+)[.]([^/#?&]+)([#?][^/]*)?$');
        var ext = url.match(rex);
        result.image_types.push(ext[2].toLowerCase().trim());
      }
    }
} catch (e) {}
return result;
''';

select
    client,
    image_type,
    count(0) as image_type_count,
    safe_divide(count(0), sum(count(0)) over (partition by client)) as image_type_pct
from
    (
        select
            _table_suffix as client,
            url,
            get_meta_og_image_types(
                json_extract_scalar(payload, '$._almanac')
            ) as almanac_info
        from `httparchive.pages.2020_08_01_*`
    ),
    unnest(almanac_info.image_types) as image_type
group by client, image_type
having image_type_count > 100
order by client, image_type_count desc
;
