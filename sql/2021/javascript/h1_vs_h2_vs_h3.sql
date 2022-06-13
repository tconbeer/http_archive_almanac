select
    client,
    percentile,
    approx_quantiles( (ajax_h1 + resources_h1), 1000) [
        offset (percentile * 10)
    ] as h1_request,
    approx_quantiles( (ajax_h2 + resources_h2), 1000) [
        offset (percentile * 10)
    ] as h2_request,
    approx_quantiles( (ajax_h3 + resources_h3), 1000) [
        offset (percentile * 10)
    ] as h3_request
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.requests_protocol.ajax_h1'
                ) as int64
            ) as ajax_h1,
            cast(
                json_extract(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.requests_protocol.resources_h1'
                ) as int64
            ) as resources_h1,
            cast(
                json_extract(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.requests_protocol.ajax_h2'
                ) as int64
            ) as ajax_h2,
            cast(
                json_extract(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.requests_protocol.resources_h2'
                ) as int64
            ) as resources_h2,
            cast(
                json_extract(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.requests_protocol.ajax_h3'
                ) as int64
            ) as ajax_h3,
            cast(
                json_extract(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.requests_protocol.resources_h3'
                ) as int64
            ) as resources_h3
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
