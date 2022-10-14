# standardSQL
# Core WebVitals by rank and device
CREATE TEMP FUNCTION IS_GOOD (good FLOAT64, needs_improvement FLOAT64, poor FLOAT64) RETURNS BOOL AS (
  good / (good + needs_improvement + poor) >= 0.75
);

CREATE TEMP FUNCTION IS_NI (good FLOAT64, needs_improvement FLOAT64, poor FLOAT64) RETURNS BOOL AS (
  good / (good + needs_improvement + poor) < 0.75 AND
  poor / (good + needs_improvement + poor) < 0.25
);

CREATE TEMP FUNCTION IS_POOR (good FLOAT64, needs_improvement FLOAT64, poor FLOAT64) RETURNS BOOL AS (
  poor / (good + needs_improvement + poor) >= 0.25
);

CREATE TEMP FUNCTION IS_NON_ZERO (good FLOAT64, needs_improvement FLOAT64, poor FLOAT64) RETURNS BOOL AS (
  good + needs_improvement + poor > 0
);

with
    base as (
        select
            date,
            origin,
            device,
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

        from `chrome-ux-report.materialized.device_summary`
        where device in ('desktop', 'phone') and date in ('2021-07-01')
    )

select
    date,
    device,
    rank_grouping as ranking,

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
group by date, device, rank_grouping
order by rank_grouping
