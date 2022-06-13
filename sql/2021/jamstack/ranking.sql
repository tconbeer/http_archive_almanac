# standardSQL
select
    _table_suffix as client,
    rank_grouping,
    total_in_rank,
    category,
    app,
    count(0) as pages_with_app,
    count(0) / total_in_rank as pct_pages_with_app
from
    (
        select distinct _table_suffix, app, category, url
        from `httparchive.technologies.2021_07_01_*`
        where
            lower(
                category
            ) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
    )
left outer join
    (
        select _table_suffix, url, rank_grouping
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
    ) using(_table_suffix, url)
join
    (
        select _table_suffix, rank_grouping, count(0) as total_in_rank
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
        group by _table_suffix, rank_grouping
    ) using(_table_suffix, rank_grouping)
group by client, rank_grouping, total_in_rank, category, app
order by pct_pages_with_app desc, app, rank_grouping
