# standardSQL
# Videos per page
# returns all the data we need from _almanac
create temporary function getvideosalmanacinfo(almanac_string string)
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
            getvideosalmanacinfo(
                json_extract_scalar(payload, '$._almanac')
            ) as video_almanac_info
        from
            `httparchive.pages.2021_07_01_*`, unnest([10, 25, 50, 75, 90]) as percentile
    )
where video_almanac_info.videos_total > 0
group by percentile, client
order by percentile, client
