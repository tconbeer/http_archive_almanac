# standardSQL
# 13_10: Top analytics providers
select
    client,
    canonicaldomain as provider,
    count(distinct page) as freq_pages,
    count(0) as freq_requests,
    total as total_pages,
    sum(count(0)) over (partition by client) as total_requests,
    round(count(distinct page) * 100 / total, 2) as pct_pages,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct_requests
from `httparchive.almanac.summary_requests`
join
    (
        select _table_suffix as client, url as page
        from `httparchive.technologies.2020_08_01_*`
        where category = 'Ecommerce'
    ) using (client, page)
join `httparchive.almanac.third_parties` on net.host(url) = domain
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by _table_suffix
    ) using (client)
where
    `httparchive.almanac.summary_requests`.date = '2020-08-01'
    and lower(category) = 'analytics'
group by client, total, provider
order by freq_requests / total desc
