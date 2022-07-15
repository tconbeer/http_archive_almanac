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
    2021 as year,
    client,
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
    # and CLS.
    safe_divide(
        count(
            distinct if(
                is_good(fast_lcp, avg_lcp, slow_lcp)
                and is_good(fast_fid, avg_fid, slow_fid) is not false
                and is_good(small_cls, medium_cls, large_cls),
                origin,
                null
            )
        ),
        count(
            distinct if(
                is_non_zero(fast_lcp, avg_lcp, slow_lcp)
                and is_non_zero(small_cls, medium_cls, large_cls),
                origin,
                null
            )
        )
    ) as pct_good_cwv
from `chrome-ux-report.materialized.device_summary`
join
    (
        select _table_suffix as client, url, app as cms
        from `httparchive.technologies.2021_07_01_*`
        where category = 'CMS'
    )
    on concat(origin, '/') = url
    and if(device = 'desktop', 'desktop', 'mobile') = client
where date = '2021-07-01'
group by client, cms
union all
select
    2020 as year,
    client,
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
    # and CLS.
    safe_divide(
        count(
            distinct if(
                is_good(fast_lcp, avg_lcp, slow_lcp)
                and is_good(fast_fid, avg_fid, slow_fid) is not false
                and is_good(small_cls, medium_cls, large_cls),
                origin,
                null
            )
        ),
        count(
            distinct if(
                is_non_zero(fast_lcp, avg_lcp, slow_lcp)
                and is_non_zero(small_cls, medium_cls, large_cls),
                origin,
                null
            )
        )
    ) as pct_good_cwv
from `chrome-ux-report.materialized.device_summary`
join
    (
        select _table_suffix as client, url, app as cms
        from `httparchive.technologies.2020_08_01_*`
        where category = 'CMS'
    )
    on concat(origin, '/') = url
    and if(device = 'desktop', 'desktop', 'mobile') = client
where date = '2020-08-01'
group by client, cms
order by origins desc
