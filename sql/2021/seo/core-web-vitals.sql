# standardSQL
# Calculate the percent of origins that comply with each Core Web Vital's "good"
# threshold for 75% or more of experiences.
CREATE TEMP FUNCTION IS_GOOD (good FLOAT64, needs_improvement FLOAT64, poor FLOAT64) RETURNS BOOL AS (
  good / (good + needs_improvement + poor) >= 0.75
);
CREATE TEMP FUNCTION IS_NON_ZERO (good FLOAT64, needs_improvement FLOAT64, poor FLOAT64) RETURNS BOOL AS (
  good + needs_improvement + poor > 0
);
select
    date,
    device,
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
    # Origins with good LCP, FID, and CLS dividied by origins with any LCP, FID, and
    # CLS.
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
where date between '2019-11-01' and '2021-07-01' and device in ('desktop', 'phone')
group by date, device
order by date desc
