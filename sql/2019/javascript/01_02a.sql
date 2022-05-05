# standardSQL
# 01_02a: Distribution of 1P/3P JS bytes
select
    percentile,
    round(
        approx_quantiles(first_party, 1000) [offset (percentile * 10)], 2
    ) as first_party_js_kbytes,
    round(
        approx_quantiles(third_party, 1000) [offset (percentile * 10)], 2
    ) as third_party_js_kbytes
from
    (
        select
            sum(if(not is_third_party, respsize, 0) / 1024) as first_party,
            sum(if(is_third_party, respsize, 0) / 1024) as third_party
        from
            (
                select
                    page,
                    url,
                    type,
                    respsize,
                    net.host(url) in (
                        select domain from `httparchive.almanac.third_parties`
                    ) as is_third_party
                from `httparchive.almanac.summary_requests`
                where date = '2019-07-01'
            )
        where type = 'script'
        group by page
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile
order by percentile
