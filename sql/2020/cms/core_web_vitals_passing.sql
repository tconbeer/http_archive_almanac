# standardSQL
# Core Web Vitals performance by CMS
CREATE TEMP FUNCTION IS_GOOD (good FLOAT64, needs_improvement FLOAT64, poor FLOAT64) RETURNS BOOL AS (
  good / (good + needs_improvement + poor) >= 0.75
);

CREATE TEMP FUNCTION IS_NON_ZERO (good FLOAT64, needs_improvement FLOAT64, poor FLOAT64) RETURNS BOOL AS (
  good + needs_improvement + poor > 0
);
select
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

    # Origins with good LCP, FID, and CLS dividied by origins with any LCP, FID, and
    # CLS.
    safe_divide(
        count(
            distinct if(
                is_good(fast_lcp, avg_lcp, slow_lcp)
                and is_good(fast_fid, avg_fid, slow_fid)
                and is_good(small_cls, medium_cls, large_cls),
                origin,
                null
            )
        ),
        count(
            distinct if(
                is_non_zero(fast_lcp, avg_lcp, slow_lcp)
                and is_non_zero(fast_fid, avg_fid, slow_fid)
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
# The CrUX 202008 dataset is not available until September 8.
where date = '2020-07-01'
group by client, cms
order by origins desc
