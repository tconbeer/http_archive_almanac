with
    websites_using_cname_tracking as (
        select distinct net.reg_domain(domain) as domain
        from
            `httparchive.almanac.cname_tracking`,
            unnest(split(substring(domains, 2, length(domains) - 2))) as domain
    ),

    totals as (
        select _table_suffix as _table_suffix, rank_grouping, count(0) as total_pages
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
        group by _table_suffix, rank_grouping
    )

select
    _table_suffix as client,
    rank_grouping,
    case
        rank_grouping
        when 10000000
        then 'all'
        else trim(cast(rank_grouping as string format '99,999,999'))
    end as rank_grouping_text,
    count(0) as num_cname_pages,
    total_pages,
    count(0) / total_pages as pct_pages
from
    `httparchive.summary_pages.2021_07_01_*`,
    unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
join totals using(_table_suffix, rank_grouping)
join websites_using_cname_tracking on domain = net.reg_domain(urlshort)
where rank <= rank_grouping
group by client, total_pages, rank_grouping
order by rank_grouping, client
