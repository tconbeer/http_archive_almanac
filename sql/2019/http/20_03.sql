# standardSQL
# 20.03 - Average percentage of resources loaded over HTTP/2 or HTTP/1.1 per site
select
    client,
    round(avg(http_1_1 / num_requests) * 100, 2) as avg_pct_http_1_1,
    round(avg(http_2 / num_requests) * 100, 2) as avg_pct_http_2
from
    (
        select
            client,
            page,
            count(0) as num_requests,
            sum(
                if(json_extract_scalar(payload, '$._protocol') = 'http/0.9', 1, 0)
            ) as http_0_9,
            sum(
                if(json_extract_scalar(payload, '$._protocol') = 'http/1.0', 1, 0)
            ) as http_1_0,
            sum(
                if(json_extract_scalar(payload, '$._protocol') = 'http/1.1', 1, 0)
            ) as http_1_1,
            sum(
                if(json_extract_scalar(payload, '$._protocol') = 'HTTP/2', 1, 0)
            ) as http_2
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
        group by client, page
    )
group by client
