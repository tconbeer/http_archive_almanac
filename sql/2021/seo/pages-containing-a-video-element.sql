# standardSQL
# Pages containing a video element
# returns all the data we need from _almanac
create temporary function getvideosalmanacinfo(almanac_string string)
returns struct
<
videos_total int64
> language js
as '''
var result = {
  videos_total: 0
};
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return result;

    if (almanac.videos && almanac.videos.total) {
      result.videos_total = almanac.videos.total;
    }
} catch (e) {}
return result;
'''
;

select
    client,
    count(0) as total,

    # Pages with videos
    countif(videos_almanac_info.videos_total > 0) as has_videos,
    safe_divide(
        countif(videos_almanac_info.videos_total > 0), count(0)
    ) as pct_has_videos

from
    (
        select
            _table_suffix as client,
            getvideosalmanacinfo(
                json_extract_scalar(payload, '$._almanac')
            ) as videos_almanac_info
        from `httparchive.pages.2021_07_01_*`
    )
group by client
