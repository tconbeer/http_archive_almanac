with
    websites_using_cname_tracking as (
        select distinct
            net.reg_domain(domain) as domain,
            net.public_suffix(net.reg_domain(domain)) as suffix,
            tracker
        from
            `httparchive.almanac.cname_tracking`,
            unnest(split(substring(domains, 2, length(domains) - 2))) as domain
    ),

    totals as (
        select _table_suffix as _table_suffix, count(0) as total_pages
        from `httparchive.summary_pages.2021_07_01_*`
        group by _table_suffix
    )

select
    _table_suffix as client,
    suffix,
    count(0) as num_pages,
    total_pages,
    count(0) / total_pages as pct_pages
from `httparchive.summary_pages.2021_07_01_*`
join totals using (_table_suffix)
join websites_using_cname_tracking on domain = net.reg_domain(urlshort)
group by client, total_pages, suffix
order by pct_pages desc, client
