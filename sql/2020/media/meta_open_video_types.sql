# standardSQL
# meta open graph video types
# returns all the data we need from _almanac
create temporary function get_meta_og_video_types(almanac_string string)
returns struct
<
video_types array
< string
>
> language js
as '''
var result = {};
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return result;

    for (var node of almanac['meta-nodes']['nodes']) {
      if (node['property'] === 'og:video') {
        if (result.video_types == null)
          result.video_types = [];
        var url = node['content'];
        // parse video extension from url
        // https://www.example.com/filename.ext?param=1234#anchor
        // first group is for file name, second for extension and
        // third one for the remaining of the url
        var rex = new RegExp('([^/]+)[.]([^/#?&]+)([#?][^/]*)?$');
        var ext = url.match(rex);
        result.video_types.push(ext[2].toLowerCase().trim());
      }
    }
} catch (e) {}
return result;
'''
;

select
    client,
    video_type,
    count(0) as video_type_count,
    safe_divide(count(0), sum(count(0)) over (partition by client)) as video_type_pct
from
    (
        select
            _table_suffix as client,
            url,
            get_meta_og_video_types(
                json_extract_scalar(payload, '$._almanac')
            ) as almanac_info
        from `httparchive.pages.2020_08_01_*`
    ),
    unnest(almanac_info.video_types) as video_type
group by client, video_type
having video_type_count > 10
order by client, video_type_count desc
;
