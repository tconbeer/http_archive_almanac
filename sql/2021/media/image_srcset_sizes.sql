# standardSQL
# images with srcset w/wo sizes
create temporary function get_media_info(media_string string)
returns struct < num_srcset_all int64,
num_srcset_sizes int64
> language js as '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    result.num_srcset_all = media.num_srcset_all;
    result.num_srcset_sizes = media.num_srcset_sizes;

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
        countif(media_info.num_srcset_sizes > 0), count(0)
    ) as pages_with_srcset_sizes_pct,
    safe_divide(
        (
            countif(media_info.num_srcset_all > 0)
            - countif(media_info.num_srcset_sizes > 0)
        ),
        count(0)
    ) as pages_with_srcset_wo_sizes_pct,
    safe_divide(
        sum(media_info.num_srcset_sizes), sum(media_info.num_srcset_all)
    ) as instances_of_srcset_sizes_pct,
    safe_divide(
        (sum(media_info.num_srcset_all) - sum(media_info.num_srcset_sizes)),
        sum(media_info.num_srcset_all)
    ) as instances_of_srcset_wo_sizes_pct
from
    (
        select
            _table_suffix as client,
            get_media_info(json_extract_scalar(payload, '$._media')) as media_info
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
