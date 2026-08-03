# standardSQL
# self_hosted_vs_hosted_with_fcp
select
    client,
    case
        when pct_self_hosted_hosted = 1
        then 'self-hosted'
        when pct_self_hosted_hosted = 0
        then 'external'
        else 'both'
    end as font_host,
    count(distinct page) as pages,
    sum(count(distinct page)) over (partition by client) as total,
    count(distinct page) / sum(count(distinct page)) over (partition by client) as pct,
    approx_quantiles(fcp, 1000)[offset(500)] as median_fcp,
    approx_quantiles(lcp, 1000)[offset(500)] as median_lcp
from
    (
        select
            client,
            page,
            countif(net.host(page) = net.host(url)) / count(0) as pct_self_hosted_hosted
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and type = 'font'
        group by client, page
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
        from `httparchive.pages.2020_08_01_*`
    ) using (client, page)
group by client, font_host
order by font_host, client
