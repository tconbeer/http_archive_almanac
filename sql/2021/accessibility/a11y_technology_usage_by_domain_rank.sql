# standardSQL
# A11Y technology usage by domain rank
select
    client,
    rank_grouping,
    total_in_rank,

    app,
    count(0) as sites_with_app,
    count(0) / total_in_rank as pct_sites_with_app
from
    (
        select _table_suffix as client, app, url
        from `httparchive.technologies.2021_07_01_*`
        where category = 'Accessibility'
    )
left outer join
    (
        select _table_suffix as client, url, rank_grouping
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
    ) using(client, url
    )
join
    (
        select _table_suffix as client, rank_grouping, count(0) as total_in_rank
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
        group by client, rank_grouping
    ) using(client, rank_grouping
    )
group by rank_grouping, total_in_rank, client, app
order by app, rank_grouping, client
