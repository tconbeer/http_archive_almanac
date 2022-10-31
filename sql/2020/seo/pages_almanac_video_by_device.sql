# standardSQL
# page almanac metrics grouped by device for video tags
# helper to create percent fields
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

# returns all the data we need from _almanac
create temporary function get_almanac_info(almanac_string string)
returns struct<videos_total int64>
language js
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
    countif(almanac_info.videos_total > 0) as has_videos,
    as_percent(countif(almanac_info.videos_total > 0), count(0)) as pct_has_videos

from
    (
        select
            _table_suffix as client,
            get_almanac_info(json_extract_scalar(payload, '$._almanac')) as almanac_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
