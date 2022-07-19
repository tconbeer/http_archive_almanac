# standardSQL
# 17_17: Distribution of # CDNs per page
select
    client,
    approx_quantiles(cdns, 1000)[offset(100)] as p10,
    approx_quantiles(cdns, 1000)[offset(250)] as p25,
    approx_quantiles(cdns, 1000)[offset(500)] as p50,
    approx_quantiles(cdns, 1000)[offset(750)] as p75,
    approx_quantiles(cdns, 1000)[offset(900)] as p90
from
    (
        select client, count(distinct _cdn_provider) as cdns
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
        group by client, page
    )
group by client
