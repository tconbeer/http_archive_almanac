# standardSQL
# 04_01: Lighthouse media scores, savings, and item lengths
CREATE TEMPORARY FUNCTION getVideoBytes(payload STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
  let data = JSON.parse(payload);
  let videoReq = data.audits['network-requests'].details.items.filter(v => /^video/.test(v.mimeType));
  let bytes = videoReq.reduce((a,c) => a + (c.transferSize || 0), 0)

  return bytes;
} catch (e) {
  return null;
}
''';

CREATE TEMPORARY FUNCTION getVideoCount(payload STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
  let data = JSON.parse(payload);
  let videoReq = data.audits['network-requests'].details.items.filter(v => /^video/.test(v.mimeType));
  return videoReq.length;
} catch (e) {
  return null;
}
''';

select
    type,
    approx_quantiles(resourcecount, 1000)[offset(100)] as count_p10,
    approx_quantiles(resourcecount, 1000)[offset(250)] as count_p25,
    approx_quantiles(resourcecount, 1000)[offset(500)] as count_p50,
    approx_quantiles(resourcecount, 1000)[offset(750)] as count_p75,
    approx_quantiles(resourcecount, 1000)[offset(900)] as count_p90,
    approx_quantiles(resourcebytes, 1000)[offset(100)] as bytes_p10,
    approx_quantiles(resourcebytes, 1000)[offset(250)] as bytes_p25,
    approx_quantiles(resourcebytes, 1000)[offset(500)] as bytes_p50,
    approx_quantiles(resourcebytes, 1000)[offset(750)] as bytes_p75,
    approx_quantiles(resourcebytes, 1000)[offset(900)] as bytes_p90,
    approx_quantiles(resourcebytes, 1000)[offset(990)] as bytes_p99,
    approx_quantiles(
        round(100 * resourcebytes / ifnull(nullif(pagebytes, 0), 0.1), 2), 1000
    )[offset(100)] as pct_p10,
    approx_quantiles(
        round(100 * resourcebytes / ifnull(nullif(pagebytes, 0), 0.1), 2), 1000
    )[offset(250)] as pct_p25,
    approx_quantiles(
        round(100 * resourcebytes / ifnull(nullif(pagebytes, 0), 0.1), 2), 1000
    )[offset(500)] as pct_p50,
    approx_quantiles(
        round(100 * resourcebytes / ifnull(nullif(pagebytes, 0), 0.1), 2), 1000
    )[offset(750)] as pct_p75,
    approx_quantiles(
        round(100 * resourcebytes / ifnull(nullif(pagebytes, 0), 0.1), 2), 1000
    )[offset(990)] as pct_p99,
    approx_quantiles(
        round(100 * resourcebytes / ifnull(nullif(pagebytes, 0), 0.1), 2), 1000
    )[offset(900)] as pct_p90
from
    (
        select
            type,
            pagebytes,
            if(
                type = 'image', totalimagecount, totalimagecount + totalvideocount
            ) as resourcecount,
            if(
                type = 'image', totalimagebytes, totalimagebytes + totalvideobytes
            ) as resourcebytes
        from
            (
                select
                    url,
                    cast(
                        json_extract_scalar(
                            report, '$.audits.resource-summary.details.items[0].size'
                        ) as int64
                    ) as pagebytes,
                    cast(
                        json_extract_scalar(
                            report, '$.audits.resource-summary.details.items[1].size'
                        ) as int64
                    ) as totalimagebytes,
                    cast(
                        json_extract_scalar(
                            report,
                            '$.audits.resource-summary.details.items[1].requestCount'
                        ) as int64
                    ) as totalimagecount,
                    getvideobytes(report) as totalvideobytes,
                    getvideocount(report) as totalvideocount
                from `httparchive.lighthouse.2019_07_01_mobile`
            )
        # we to make this a little easier to read we unnest with just image and
        # image+video
        # it's important to remember that each of the results is mutually exclusive
        # and should not imply addition
        # that is, you cannot assume that image + video at the p75 and image at p75
        # are the same webpages being collected
        # if we wanted to do more advanced percentile based on page size, we would
        # need a different statistics engine (eg: R)
        cross join unnest(['image', 'image+video']) as type
    )
group by type
