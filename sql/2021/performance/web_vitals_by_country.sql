# standardSQL
# Core WebVitals by country
create temp function is_good(
    good float64, needs_improvement float64, poor float64
) returns bool as (safe_divide(good, (good + needs_improvement + poor)) >= 0.75)
;

create temp function is_poor(
    good float64, needs_improvement float64, poor float64
) returns bool as (safe_divide(poor, (good + needs_improvement + poor)) >= 0.25)
;

create temp function is_ni(
    good float64, needs_improvement float64, poor float64
) returns bool as (
    not is_good(good, needs_improvement, poor) and not is_poor(
        good, needs_improvement, poor
    )
)
;

create temp function is_non_zero(
    good float64, needs_improvement float64, poor float64
) returns bool as (good + needs_improvement + poor > 0)
;

with
    base as (
        select
            origin,
            country_code,

            sum(fast_fid) / sum(fast_fid + avg_fid + slow_fid) as fast_fid,
            sum(avg_fid) / sum(fast_fid + avg_fid + slow_fid) as avg_fid,
            sum(slow_fid) / sum(fast_fid + avg_fid + slow_fid) as slow_fid,

            sum(fast_lcp) / sum(fast_lcp + avg_lcp + slow_lcp) as fast_lcp,
            sum(avg_lcp) / sum(fast_lcp + avg_lcp + slow_lcp) as avg_lcp,
            sum(slow_lcp) / sum(fast_lcp + avg_lcp + slow_lcp) as slow_lcp,

            sum(small_cls) / sum(small_cls + medium_cls + large_cls) as small_cls,
            sum(medium_cls) / sum(small_cls + medium_cls + large_cls) as medium_cls,
            sum(large_cls) / sum(small_cls + medium_cls + large_cls) as large_cls,

            sum(fast_fcp) / sum(fast_fcp + avg_fcp + slow_fcp) as fast_fcp,
            sum(avg_fcp) / sum(fast_fcp + avg_fcp + slow_fcp) as avg_fcp,
            sum(slow_fcp) / sum(fast_fcp + avg_fcp + slow_fcp) as slow_fcp,

            sum(fast_ttfb) / sum(fast_ttfb + avg_ttfb + slow_ttfb) as fast_ttfb,
            sum(avg_ttfb) / sum(fast_ttfb + avg_ttfb + slow_ttfb) as avg_ttfb,
            sum(slow_ttfb) / sum(fast_ttfb + avg_ttfb + slow_ttfb) as slow_ttfb

        from `chrome-ux-report.materialized.country_summary`
        where yyyymm = 202107
        group by origin, country_code
    )

select
    `chrome-ux-report`.experimental.get_country(country_code) as country,

    count(distinct origin) as total_origins,

    # Good CWV with optional FID
    safe_divide(
        count(
            distinct if(
                is_good(fast_fid, avg_fid, slow_fid) is not false and is_good(
                    fast_lcp, avg_lcp, slow_lcp
                ) and
                is_good(small_cls, medium_cls, large_cls),
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
    ) as pct_cwv_good,

    safe_divide(
        count(distinct if(is_good(fast_lcp, avg_lcp, slow_lcp), origin, null)),
        count(distinct if(is_non_zero(fast_lcp, avg_lcp, slow_lcp), origin, null))
    ) as pct_lcp_good,
    safe_divide(
        count(distinct if(is_ni(fast_lcp, avg_lcp, slow_lcp), origin, null)),
        count(distinct if(is_non_zero(fast_lcp, avg_lcp, slow_lcp), origin, null))
    ) as pct_lcp_ni,
    safe_divide(
        count(distinct if(is_poor(fast_lcp, avg_lcp, slow_lcp), origin, null)),
        count(distinct if(is_non_zero(fast_lcp, avg_lcp, slow_lcp), origin, null))
    ) as pct_lcp_poor,

    safe_divide(
        count(distinct if(is_good(fast_fid, avg_fid, slow_fid), origin, null)),
        count(distinct if(is_non_zero(fast_fid, avg_fid, slow_fid), origin, null))
    ) as pct_fid_good,
    safe_divide(
        count(distinct if(is_ni(fast_fid, avg_fid, slow_fid), origin, null)),
        count(distinct if(is_non_zero(fast_fid, avg_fid, slow_fid), origin, null))
    ) as pct_fid_ni,
    safe_divide(
        count(distinct if(is_poor(fast_fid, avg_fid, slow_fid), origin, null)),
        count(distinct if(is_non_zero(fast_fid, avg_fid, slow_fid), origin, null))
    ) as pct_fid_poor,

    safe_divide(
        count(distinct if(is_good(small_cls, medium_cls, large_cls), origin, null)),
        count(distinct if(is_non_zero(small_cls, medium_cls, large_cls), origin, null))
    ) as pct_cls_good,
    safe_divide(
        count(distinct if(is_ni(small_cls, medium_cls, large_cls), origin, null)),
        count(distinct if(is_non_zero(small_cls, medium_cls, large_cls), origin, null))
    ) as pct_cls_ni,
    safe_divide(
        count(distinct if(is_poor(small_cls, medium_cls, large_cls), origin, null)),
        count(distinct if(is_non_zero(small_cls, medium_cls, large_cls), origin, null))
    ) as pct_cls_poor,

    safe_divide(
        count(distinct if(is_good(fast_fcp, avg_fcp, slow_fcp), origin, null)),
        count(distinct if(is_non_zero(fast_fcp, avg_fcp, slow_fcp), origin, null))
    ) as pct_fcp_good,
    safe_divide(
        count(distinct if(is_ni(fast_fcp, avg_fcp, slow_fcp), origin, null)),
        count(distinct if(is_non_zero(fast_fcp, avg_fcp, slow_fcp), origin, null))
    ) as pct_fcp_ni,
    safe_divide(
        count(distinct if(is_poor(fast_fcp, avg_fcp, slow_fcp), origin, null)),
        count(distinct if(is_non_zero(fast_fcp, avg_fcp, slow_fcp), origin, null))
    ) as pct_fcp_poor,

    safe_divide(
        count(distinct if(is_good(fast_ttfb, avg_ttfb, slow_ttfb), origin, null)),
        count(distinct if(is_non_zero(fast_ttfb, avg_ttfb, slow_ttfb), origin, null))
    ) as pct_ttfb_good,
    safe_divide(
        count(distinct if(is_ni(fast_ttfb, avg_ttfb, slow_ttfb), origin, null)),
        count(distinct if(is_non_zero(fast_ttfb, avg_ttfb, slow_ttfb), origin, null))
    ) as pct_ttfb_ni,
    safe_divide(
        count(distinct if(is_poor(fast_ttfb, avg_ttfb, slow_ttfb), origin, null)),
        count(distinct if(is_non_zero(fast_ttfb, avg_ttfb, slow_ttfb), origin, null))
    ) as pct_ttfb_poor

from base
group by country
order by total_origins desc
