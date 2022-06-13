# standardSQL
# List of the top used response headers
select
    client,
    header_name as header,
    percentile,
    count(distinct url) as urls,
    approx_quantiles(header_length, 1000) [offset (percentile * 10)] as length
from
    (
        select
            client,
            url,
            json_extract_scalar(header, '$.name') as header_name,
            length(json_extract_scalar(header, '$.value')) as header_length
        from
            `httparchive.almanac.requests`,
            unnest(json_extract_array(response_headers)) as header
        where date = '2021-07-01'
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by client, header, percentile
having count(distinct url) > 100000
order by client, header, percentile
