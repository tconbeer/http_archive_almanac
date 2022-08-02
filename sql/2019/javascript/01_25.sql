# standardSQL
# 01_25: % of sites that ship sourcemaps.
select
    client,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from `httparchive.almanac.summary_response_bodies`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
where
    date = '2019-07-01'
    and type = 'script'
    and body like '%sourceMappingURL%'
    and net.reg_domain(page) = net.reg_domain(url)
group by client, total
