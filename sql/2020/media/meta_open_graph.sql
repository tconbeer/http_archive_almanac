# standardSQL
# usage meta open graph
# returns all the data we need from _almanac
create temporary function get_meta_og_info(almanac_string string)
returns struct < meta_og_image boolean,
meta_og_video boolean
> language js as '''
var result = {};
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return result;

    result.meta_og_image = false;
    result.meta_og_video = false;
    for (var node of almanac['meta-nodes']['nodes']) {
      if (node['property'] === 'og:image')
        result.meta_og_image = true;
      else if (node['property'] === 'og:video')
        result.meta_og_video = true;
    }
} catch (e) {}
return result;
'''
;

select
    client,
    countif(almanac_info.meta_og_image) / count(0) as meta_og_image_pct,
    countif(almanac_info.meta_og_video) / count(0) as meta_og_video_pct,
    countif(almanac_info.meta_og_image and almanac_info.meta_og_video)
    / count(0) as meta_og_image_video_pct
from
    (
        select
            _table_suffix as client,
            url,
            get_meta_og_info(json_extract_scalar(payload, '$._almanac')) as almanac_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
order by client
;
