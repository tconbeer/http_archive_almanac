# cms passing core web vitals
create temp function is_good(
    good float64, needs_improvement float64, poor float64
) returns bool as (good / (good + needs_improvement + poor) >= 0.75)
;

create temp function is_non_zero(
    good float64, needs_improvement float64, poor float64
) returns bool as (good + needs_improvement + poor > 0)
;

select
    client,
    `chrome-ux-report`.experimental.get_country(country_code) as geo,
    cms,
    count(distinct origin) as origins,
    # Origins with good LCP divided by origins with any LCP.
    safe_divide(
        count(distinct if(is_good(fast_lcp, avg_lcp, slow_lcp), origin, null)),
        count(distinct if(is_non_zero(fast_lcp, avg_lcp, slow_lcp), origin, null))
    ) as pct_good_lcp,

    # Origins with good FID divided by origins with any FID.
    safe_divide(
        count(distinct if(is_good(fast_fid, avg_fid, slow_fid), origin, null)),
        count(distinct if(is_non_zero(fast_fid, avg_fid, slow_fid), origin, null))
    ) as pct_good_fid,

    # Origins with good CLS divided by origins with any CLS.
    safe_divide(
        count(distinct if(is_good(small_cls, medium_cls, large_cls), origin, null)),
        count(distinct if(is_non_zero(small_cls, medium_cls, large_cls), origin, null))
    ) as pct_good_cls,

    # Origins with good LCP, FID (optional), and CLS divided by origins with any LCP
    # and CLS. FID is optional!
    safe_divide(
        count(
            distinct if(
                is_good(fast_lcp, avg_lcp, slow_lcp) and
                is_good(fast_fid, avg_fid, slow_fid) is not false and is_good(
                    small_cls, medium_cls, large_cls
                ),
                origin,
                null
            )
        ),
        count(
            distinct if(
                is_non_zero(fast_lcp, avg_lcp, slow_lcp) and
                is_non_zero(small_cls, medium_cls, large_cls),
                origin,
                null
            )
        )
    ) as pct_good_cwv
from
    (
        select
            *,
            concat(origin, '/') as url,
            if(device = 'desktop', 'desktop', 'mobile') as client
        from `chrome-ux-report.materialized.country_summary`
        where yyyymm = 202107 and device in ('desktop', 'phone')
    )
join
    (
        select distinct _table_suffix as client, url, app as cms
        from `httparchive.technologies.2021_07_01_*`
        where category = 'CMS'
    )
    using
    (client, url)
group by client, geo, cms
having origins > 1000
order by origins desc
