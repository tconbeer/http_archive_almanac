# standardSQL
# 06_01: counts the local and hosted fonts
select
    client,
    countif(net.host(page) != net.host(url)) as hosted,
    countif(net.host(page) = net.host(url)) as local,
    count(0) as total,
    round(countif(net.host(page) != net.host(url)) * 100 / count(0), 2) as pct_hosted,
    round(countif(net.host(page) = net.host(url)) * 100 / count(0), 2) as pct_local
from `httparchive.almanac.requests`
where date = '2019-07-01' and type = 'font'
group by client
