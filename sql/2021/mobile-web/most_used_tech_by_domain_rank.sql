# standardSQL
# Most used technologies by domain rank - mobile only
select
    rank_grouping,
    total_in_rank,

    category,
    app,
    count(0) as pages_with_app,
    count(0) / total_in_rank as pct_pages_with_app
from (select app, category, url from `httparchive.technologies.2021_07_01_mobile`)
left outer join
    (
        select url, rank_grouping
        from
            `httparchive.summary_pages.2021_07_01_mobile`,
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
    ) using(url
    )
join
    (
        select rank_grouping, count(0) as total_in_rank
        from
            `httparchive.summary_pages.2021_07_01_mobile`,
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
        group by rank_grouping
    ) using(rank_grouping
    )
group by rank_grouping, total_in_rank, category, app
order by app, rank_grouping
