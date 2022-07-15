# standardSQL
# breadkdown of asynchronous JavaScript and XML requests per page
select
    client,
    percentile,
    approx_quantiles(
        ajax_requests_total, 1000) [offset (percentile * 10)
    ] as ajax_requests_total
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract(
                    json_extract_scalar(payload, '$._javascript'),
                    '$.ajax_requests.total'
                ) as int64
            ) as ajax_requests_total
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
where ajax_requests_total > 0
group by percentile, client
order by percentile, client
