# standardSQL
# 06_02: counts the host_url of a given font
select
    client,
    font_host.value as host,
    font_host.count as freq,
    total_requests as total,
    round(font_host.count * 100 / total_requests, 2) as pct_requests
from
    (
        select
            client,
            approx_top_count(net.host(url), 500) as font_host,
            count(0) as total_requests
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and type = 'font' and net.host(url) != net.host(page)
        group by client
    ),
    unnest(font_host) as font_host
where font_host.count > 1000
order by freq / total desc
