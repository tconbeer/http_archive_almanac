# standardSQL
# images with srcset descriptor_x descriptor_w
# returns all the data we need from _media
create temporary function get_media_info(media_string string)
returns struct < num_srcset_all int64,
num_srcset_descriptor_x int64,
num_srcset_descriptor_w int64
> language js as '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    result.num_srcset_all = media.num_srcset_all;
    result.num_srcset_descriptor_x = media.num_srcset_descriptor_x;
    result.num_srcset_descriptor_w = media.num_srcset_descriptor_w;

} catch (e) {}
return result;
'''
;

select
    client,
    safe_divide(
        countif(media_info.num_srcset_all > 0), count(0)
    ) as pages_with_srcset_pct,
    safe_divide(
        countif(media_info.num_srcset_descriptor_x > 0), count(0)
    ) as pages_with_srcset_descriptor_x_pct,
    safe_divide(
        countif(media_info.num_srcset_descriptor_w > 0), count(0)
    ) as pages_with_srcset_descriptor_w_pct,
    safe_divide(
        sum(media_info.num_srcset_descriptor_x), sum(media_info.num_srcset_all)
    ) as instances_of_srcset_descriptor_x_pct,
    safe_divide(
        sum(media_info.num_srcset_descriptor_w), sum(media_info.num_srcset_all)
    ) as instances_of_srcset_descriptor_w_pct
from
    (
        select
            _table_suffix as client,
            get_media_info(json_extract_scalar(payload, '$._media')) as media_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
order by client
