# standardSQL
# 01_09: Changes in top JS libraries
select
    app,
    client,
    freq_2018,
    round(pct_2018 * 100, 2) as pct_2018,
    freq_2019,
    round(pct_2019 * 100, 2) as pct_2019,
    round((pct_2019 - pct_2018) * 100, 2) as pct_pt_change,
    if(
        pct_2018 > 0, round((pct_2019 - pct_2018) * 100 / pct_2018, 2), null
    ) as pct_change
from
    (
        select
            app,
            _table_suffix as client,
            count(distinct url) as freq_2018,
            count(distinct url) / total as pct_2018
        from
            (
                select _table_suffix, count(url) as total
                from `httparchive.summary_pages.2018_07_01_*`
                group by _table_suffix
            )
        join `httparchive.technologies.2018_07_01_*` using(_table_suffix)
        group by app, client, total
    )
join
    (
        select
            app,
            _table_suffix as client,
            count(distinct url) as freq_2019,
            count(distinct url) / total as pct_2019
        from
            (
                select _table_suffix, count(url) as total
                from `httparchive.summary_pages.2019_07_01_*`
                group by _table_suffix
            )
        join `httparchive.technologies.2019_07_01_*` using(_table_suffix)
        where category = 'JavaScript Libraries'
        group by app, client, total
    )
    using(app, client)
where freq_2019 > 10
order by freq_2019 desc
