# standardSQL
# Core Web Vitals distribution by CMS
# 
# Note that this is an unweighted average of all sites per CMS.
# Performance of sites with millions of visitors as weighted the same as small sites.
select
    client,
    cms,
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
from `chrome-ux-report.materialized.device_summary`
join
    (
        select _table_suffix as client, url, app as cms
        from `httparchive.technologies.2020_08_01_*`
        where category = 'CMS'
    ) on concat(origin, '/') = url and if(
        device = 'desktop', 'desktop', 'mobile'
    ) = client
# The CrUX 202008 dataset is not available until September 8.
where date = '2020-07-01'
group by client, cms
order by origins desc
