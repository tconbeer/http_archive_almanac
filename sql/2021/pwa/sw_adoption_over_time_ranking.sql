# standardSQL
# SW adoption over time, including ranking
select
    regexp_replace(yyyymmdd, r'(\d{4})(\d{2})(\d{2})', r'\1-\2\-3') as date,
    client,
    rank_grouping,
    case
        when rank_grouping = 10000000 then 'all' else format("%'d", rank_grouping)
    end as ranking,
    count(0) as freq,
    total,
    count(0) / total as pct
from
    (
        select distinct format_date('%Y%m%d', yyyymmdd) as yyyymmdd, client, url, rank
        from `httparchive.blink_features.features`
        where feature = 'ServiceWorkerControlledPage' and yyyymmdd >= '2021-05-01'
    ),
    unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
join
    (
        select
            replace(substr(_table_suffix, 0, 10), '_', '') as yyyymmdd,
            substr(_table_suffix, 12) as client,
            rank_grouping,
            count(0) as total
        from
            `httparchive.summary_pages.*`,
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where _table_suffix > '2021_05_01' and rank <= rank_grouping
        group by yyyymmdd, rank_grouping, client
    )
    using
    (yyyymmdd, client, rank_grouping)
where rank <= rank_grouping
group by yyyymmdd, client, total, rank_grouping
order by date desc, rank_grouping, client
