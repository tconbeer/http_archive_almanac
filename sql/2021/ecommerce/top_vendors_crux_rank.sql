# standardSQL
# Ranking top vendors in terms of top 10 all the way to top 10000000
# Uses the Crux rank field in the summary_pages table
# standardSQL
select
    client,
    rank,
    app,
    count(distinct url) as freq,
    total_pages,
    count(distinct url) / total_pages as pct,
    count(distinct url) / rank as rank_pct
from
    (
        select _table_suffix as client, app, url
        from `httparchive.technologies.2021_07_01_*`
        where
            category = 'Ecommerce'
            and app != 'Cart Functionality'
            and app != 'Google Analytics Enhanced eCommerce'
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    ) using (client)
join
    (
        select _table_suffix as client, url, max(rank) as rank
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest([10, 100, 1000, 10000, 100000, 1000000, 10000000]) as rank_magnitude
        where rank <= rank_magnitude
        group by client, url
    ) using (client, url)
group by client, rank, app, total_pages
order by rank, pct desc
