select *, domains_using_wasm / all_domains as domains_using_wasm_pct
from
    (
        select
            _table_suffix as client, count(distinct net.reg_domain(url)) as all_domains
        from `httparchive.summary_pages.2021_09_01_*`
        group by client
    )
join
    (
        select client, count(distinct net.reg_domain(page)) as domains_using_wasm
        from `httparchive.almanac.wasm_stats`
        where date = '2021-09-01'
        group by client
    )
    using(client)
order by client
