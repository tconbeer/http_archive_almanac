# standardSQL
# percientile data from almanac per device for video tags - only taking into account
# pages that have at least one video
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
    percentile,
    client,
    count(distinct url) as total,

    # videos per page
    approx_quantiles(almanac_info.videos_total, 1000)[
        offset(percentile * 10)
    ] as videos_count

from
    (
        select
            _table_suffix as client,
            percentile,
            url,
            get_almanac_info(json_extract_scalar(payload, '$._almanac')) as almanac_info
        from
            `httparchive.pages.2020_08_01_*`, unnest([10, 25, 50, 75, 90]) as percentile
    )
where almanac_info.videos_total > 0
group by percentile, client
order by percentile, client
