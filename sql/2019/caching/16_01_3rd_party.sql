# standardSQL
# 16_01_3rd_party: TTL by resource and party by party
select
    client,
    percentile,
    type,
    if(
        strpos(net.host(url), regexp_extract(net.reg_domain(page), r'([\w-]+)')) > 0,
        1,
        3
    ) as party,
    approx_quantiles(expage, 1000) [offset (percentile * 10)] as ttl
from `httparchive.almanac.requests`, unnest( [10, 25, 50, 75, 90]) as percentile
where date = '2019-07-01' and expage > 0
group by percentile, client, party, type
order by type, percentile, client, party
