# standardSQL
# 13_06: Distribution of image stats
select
    client,
    format,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.summary_requests`
join
    (
        select distinct _table_suffix as client, url as page
        from `httparchive.technologies.2021_07_01_*`
        where
            category = 'Ecommerce'
            and (
                app != 'Cart Functionality'
                and app != 'Google Analytics Enhanced eCommerce'
            )
    )
    using(client, page)
where type = 'image'
group by client, format
order by freq / total desc
