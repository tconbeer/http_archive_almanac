# standardSQL
# Distribution of external stylesheet transfer size (compressed).
with
    summary_pages as (
        select 2019 as year, _table_suffix as client, bytescss
        from `httparchive.summary_pages.2019_07_01_*`
        union all
        select 2020 as year, _table_suffix as client, bytescss
        from `httparchive.summary_pages.2020_08_01_*`
        union all
        select 2021 as year, _table_suffix as client, bytescss
        from `httparchive.summary_pages.2021_07_01_*`
    )

select
    year,
    percentile,
    client,
    approx_quantiles(bytescss / 1024, 1000) [
        offset (percentile * 10)
    ] as stylesheet_kbytes
from summary_pages, unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by year, percentile, client
order by year, percentile, client
