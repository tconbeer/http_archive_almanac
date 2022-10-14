# standardSQL
# page almanac metrics grouped by device for video tags
# helper to create percent fields
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

# returns all the data we need from _almanac
CREATE TEMPORARY FUNCTION get_almanac_info(almanac_string STRING)
RETURNS STRUCT<
  videos_total INT64
> LANGUAGE js AS '''
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
''';

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
