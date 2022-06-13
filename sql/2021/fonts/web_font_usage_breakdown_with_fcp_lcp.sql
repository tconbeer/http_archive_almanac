# standardSQL
# web_font_usage_breakdown_with_fcp_lcp
select
    client,
    net.host(url) as host,
    count(distinct page) as pages,
    sum(count(distinct page)) over (partition by client) as total,
    count(distinct page) / sum(count(distinct page)) over (partition by client) as pct,
    approx_quantiles(fcp, 1000) [offset (500)] as median_fcp,
    approx_quantiles(lcp, 1000) [offset (500)] as median_lcp
from
    (
        select client, page, url
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and type = 'font' and net.host(page) != net.host(url)
        group by client, url, page
    )
join
    (
        select
            _table_suffix as client,
            url as page,
            cast(
                json_extract_scalar(
                    payload, "$['_chromeUserTiming.firstContentfulPaint']"
                ) as int64
            ) as fcp,
            cast(
                json_extract_scalar(
                    payload, "$['_chromeUserTiming.LargestContentfulPaint']"
                ) as int64
            ) as lcp
        from `httparchive.pages.2021_07_01_*`
    )
    using
    (client, page)
group by client, host
having pages >= 1000
order by pct desc
