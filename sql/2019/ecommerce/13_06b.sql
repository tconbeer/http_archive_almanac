# standardSQL
# 13_06: Distribution of image stats
select
    client,
    format,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.summary_requests`
join
    (
        select _table_suffix as client, url as page
        from `httparchive.technologies.2019_07_01_*`
        where category = 'Ecommerce'
    ) using (client, page)
where date = '2019-07-01' and type = 'image'
group by client, format
order by freq / total desc
