select
    client,
    percentile,
    approx_quantiles(xmlhttprequest_total, 1000) [
        offset (percentile * 10)
    ] as xmlhttprequest_total,
    approx_quantiles(fetch_total, 1000) [offset (percentile * 10)] as fetch_total,
    approx_quantiles(beacon_total, 1000) [offset (percentile * 10)] as beacon_total
from
    (
        select
            _table_suffix as client,
            json_extract(
                json_extract_scalar(payload, '$._javascript'),
                '$.ajax_requests.xmlhttprequest'
            ) as xmlhttprequest_total,
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.ajax_requests.fetch'
            ) as fetch_total,
            json_extract(
                json_extract_scalar(payload, '$._javascript'), '$.ajax_requests.beacon'
            ) as beacon_total
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
