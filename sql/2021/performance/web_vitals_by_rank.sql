# standardSQL
# Core WebVitals by rank
create temp function is_good(good float64, needs_improvement float64, poor float64)
returns bool
as (good / (good + needs_improvement + poor) >= 0.75)
;

create temp function is_ni(good float64, needs_improvement float64, poor float64)
returns bool
as
    (
        good / (good + needs_improvement + poor) < 0.75
        and poor / (good + needs_improvement + poor) < 0.25
    )
;

create temp function is_poor(good float64, needs_improvement float64, poor float64)
returns bool
as (poor / (good + needs_improvement + poor) >= 0.25)
;

create temp function is_non_zero(good float64, needs_improvement float64, poor float64)
returns bool
as (good + needs_improvement + poor > 0)
;

with
    base as (
        select
            date,
            origin,
            rank,

            fast_fid,
            avg_fid,
            slow_fid,

            fast_lcp,
            avg_lcp,
            slow_lcp,

            small_cls,
            medium_cls,
            large_cls,

            fast_fcp,
            avg_fcp,
            slow_fcp,

            fast_ttfb,
            avg_ttfb,
            slow_ttfb

        from `chrome-ux-report.materialized.metrics_summary`
        where date in ('2021-07-01')
    )

select
    date,
    case
        when rank_grouping = 10000000 then 'all' else cast(rank_grouping as string)
    end as ranking,

    count(distinct origin) as total_origins,

    # Good CWV with optional FID
    safe_divide(
        count(
            distinct if(
                is_good(fast_fid, avg_fid, slow_fid) is not false
                and is_good(fast_lcp, avg_lcp, slow_lcp)
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

from base, unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
where rank <= rank_grouping
group by date, rank_grouping
order by rank_grouping
