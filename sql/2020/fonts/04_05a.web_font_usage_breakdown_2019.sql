# standardSQL
# web_font_usage_breakdown_2019
select
    client,
    net.host(url) as host,
    count(distinct page) as pages,
    sum(count(distinct page)) over (partition by client) as total,
    count(distinct page) / sum(count(distinct page)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2019-07-01' and type = 'font' and net.host(page) != net.host(url)
group by client, url, page
having pages >= 1000
order by pct desc
