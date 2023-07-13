# standardSQL
# Overall A11Y technology usage by domain rank
select
    client,
    rank_grouping,
    total_in_rank,

    count(distinct url) as sites_with_a11y_tech,
    count(distinct url) / total_in_rank as pct_sites_with_a11y_tech
from
    (
        select _table_suffix as client, url
        from `httparchive.technologies.2021_07_01_*`
        where category = 'Accessibility'
    )
left outer join
    (
        select _table_suffix as client, url, rank_grouping
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
    ) using (client, url)
join
    (
        select _table_suffix as client, rank_grouping, count(0) as total_in_rank
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
        group by client, rank_grouping
    ) using (client, rank_grouping)
group by rank_grouping, total_in_rank, client
order by client, rank_grouping
