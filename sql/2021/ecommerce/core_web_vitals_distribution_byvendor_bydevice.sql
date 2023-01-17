# standardSQL
# Core Web Vitals distribution by Ecommerce vendor
#
# Note that this is an unweighted average of all sites per Ecommerce vendor.
# Performance of sites with millions of visitors as weighted the same as small sites.
select
    client,
    ecomm,
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
        select distinct _table_suffix as client, url, app as ecomm
        from `httparchive.technologies.2021_07_01_*`
        where
            category = 'Ecommerce'
            and (
                app != 'Cart Functionality'
                and app != 'Google Analytics Enhanced eCommerce'
            )
    )
    on concat(origin, '/') = url
    and if(device = 'desktop', 'desktop', 'mobile') = client
where date = '2021-07-01'
group by client, ecomm
order by origins desc
