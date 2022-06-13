# standardSQL
# 17_04: Distribution of response header size
select
    client,
    cdn,
    count(0) as requests,
    approx_quantiles(resheader, 1000) [offset (100)] as p10,
    approx_quantiles(resheader, 1000) [offset (250)] as p25,
    approx_quantiles(resheader, 1000) [offset (500)] as p50,
    approx_quantiles(resheader, 1000) [offset (750)] as p75,
    approx_quantiles(resheader, 1000) [offset (900)] as p90
from
    (
        select
            client,
            cast(json_extract(payload, '$.response.headersSize') as int64) as resheader,
            _cdn_provider as cdn
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and _cdn_provider != ''
    )
group by client, cdn
order by requests desc, client
