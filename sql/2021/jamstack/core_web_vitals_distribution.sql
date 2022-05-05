# standardSQL
# Core Web Vitals distribution by SSG
# 
# Note that this is an unweighted average of all sites per SSG.
# Performance of sites with millions of visitors as weighted the same as small sites.
select
    client,
    app,
    count(distinct origin) as origins,
    sum(fast_lcp) / (sum(fast_lcp) + sum(avg_lcp) + sum(slow_lcp)) as good_lcp,
    sum(avg_lcp) / (sum(fast_lcp) + sum(avg_lcp) + sum(slow_lcp)) as ni_lcp,
    sum(slow_lcp) / (sum(fast_lcp) + sum(avg_lcp) + sum(slow_lcp)) as poor_lcp,

    sum(fast_fid) / (sum(fast_fid) + sum(avg_fid) + sum(slow_fid)) as good_fid,
    sum(avg_fid) / (sum(fast_fid) + sum(avg_fid) + sum(slow_fid)) as ni_fid,
    sum(slow_fid) / (sum(fast_fid) + sum(avg_fid) + sum(slow_fid)) as poor_fid,

    sum(small_cls) / (sum(small_cls) + sum(medium_cls) + sum(large_cls)) as good_cls,
    sum(medium_cls) / (sum(small_cls) + sum(medium_cls) + sum(large_cls)) as ni_cls,
    sum(large_cls) / (sum(small_cls) + sum(medium_cls) + sum(large_cls)) as poor_cls
from
    (
        select
            if(device = 'desktop', 'desktop', 'mobile') as client,
            concat(origin, '/') as url,
            *
        from `chrome-ux-report.materialized.device_summary`
        where date = '2021-07-01'
    )
join
    (
        select client, page as url
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and firsthtml
    )
    using
    (client, url)
join
    (
        select distinct _table_suffix as client, app, url
        from `httparchive.technologies.2021_07_01_*`
        where
            lower(
                category
            ) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
    )
    using(client, url)
group by app, client
order by origins desc
