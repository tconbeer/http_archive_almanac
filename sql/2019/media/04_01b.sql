# standardSQL
# 04_01: Lighthouse media scores for offscreen images
select
    count(0) as pagecount,
    approx_quantiles(offscreenimagescount, 1000) [offset (100)] as count_p10,
    approx_quantiles(offscreenimagescount, 1000) [offset (250)] as count_p25,
    approx_quantiles(offscreenimagescount, 1000) [offset (500)] as count_p50,
    approx_quantiles(offscreenimagescount, 1000) [offset (750)] as count_p75,
    approx_quantiles(offscreenimagescount, 1000) [offset (900)] as count_p90,
    approx_quantiles(offscreenimagesbytes, 1000) [offset (100)] as bytes_p10,
    approx_quantiles(offscreenimagesbytes, 1000) [offset (250)] as bytes_p25,
    approx_quantiles(offscreenimagesbytes, 1000) [offset (500)] as bytes_p50,
    approx_quantiles(offscreenimagesbytes, 1000) [offset (750)] as bytes_p75,
    approx_quantiles(offscreenimagesbytes, 1000) [offset (900)] as bytes_p90,
    approx_quantiles(
        round(100 * offscreenimagesbytes / (totalimagebytes + 0.1), 2), 1000
    ) [offset (100)] as pctimagebytes_p10,
    approx_quantiles(
        round(100 * offscreenimagesbytes / (totalimagebytes + 0.1), 2), 1000
    ) [offset (250)] as pctimagebytes_p25,
    approx_quantiles(
        round(100 * offscreenimagesbytes / (totalimagebytes + 0.1), 2), 1000
    ) [offset (500)] as pctimagebytes_p50,
    approx_quantiles(
        round(100 * offscreenimagesbytes / (totalimagebytes + 0.1), 2), 1000
    ) [offset (750)] as pctimagebytes_p75,
    approx_quantiles(
        round(100 * offscreenimagesbytes / (totalimagebytes + 0.1), 2), 1000
    ) [offset (900)] as pctimagebytes_p90
from
    (
        select
            url,
            cast(
                json_extract_scalar(
                    report, '$.audits.resource-summary.details.items[0].size'
                ) as int64
            ) as totalbytes,
            cast(
                json_extract_scalar(
                    report, '$.audits.resource-summary.details.items[1].size'
                ) as int64
            ) as totalimagebytes,
            cast(
                json_extract_scalar(
                    report, '$.audits.offscreen-images.details.overallSavingsBytes'
                ) as int64
            ) as offscreenimagesbytes,
            if(
                regex_contains(
                    json_extract(report, '$.audits.offscreen-images.details.items'), ','
                ),
                array_length(
                    split(
                        json_extract(report, '$.audits.offscreen-images.details.items'),
                        ','
                    )
                ),
                0
            ) as offscreenimagescount,
            cast(
                json_extract_scalar(
                    report, '$.audits.uses-optimized-images.details.overallSavingsBytes'
                ) as int64
            ) as unoptimizedimagesbytes,
            if(
                regex_contains(
                    json_extract(
                        report, '$.audits.uses-optimized-images.details.items'
                    ),
                    ','
                ),
                array_length(
                    split(
                        json_extract(
                            report, '$.audits.uses-optimized-images.details.items'
                        ),
                        ','
                    )
                ),
                0
            ) as unoptimizedimagescount
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
