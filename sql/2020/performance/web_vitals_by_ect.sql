# standardSQL
# WebVitals by effective connection type
create temp function is_good(
    good float64, needs_improvement float64, poor float64
) returns bool as (safe_divide(good, (good + needs_improvement + poor)) >= 0.75)
;

create temp function is_ni(
    good float64, needs_improvement float64, poor float64
) returns bool as (
    safe_divide(good, (good + needs_improvement + poor)) < 0.75 and safe_divide(
        poor, (good + needs_improvement + poor)
    ) < 0.25
)
;

create temp function is_poor(
    good float64, needs_improvement float64, poor float64
) returns bool as (safe_divide(poor, (good + needs_improvement + poor)) >= 0.25)
;

create temp function is_non_zero(
    good float64, needs_improvement float64, poor float64
) returns bool as (good + needs_improvement + poor > 0)
;

with
    base as (
        select
            origin,
            effective_connection_type.name as network,
            layout_instability,
            largest_contentful_paint,
            first_input,
            first_contentful_paint,
            experimental.time_to_first_byte as time_to_first_byte
        from `chrome-ux-report.all.202008`
    ),

    cls as (
        select
            origin,
            network,
            sum(if(bin.start < 0.1, bin.density, 0)) as small,
            sum(if(bin.start > 0.1 and bin.start < 0.25, bin.density, 0)) as medium,
            sum(if(bin.start >= 0.25, bin.density, 0)) as large,
            `chrome-ux-report`.experimental.percentile_numeric(
                array_agg(bin), 75
            ) as p75
        from base
        left join
            unnest(layout_instability.cumulative_layout_shift.histogram.bin) as bin
        group by origin, network
    ),

    lcp as (
        select
            origin,
            network,
            sum(if(bin.start < 2500, bin.density, 0)) as fast,
            sum(if(bin.start >= 2500 and bin.start < 4000, bin.density, 0)) as avg,
            sum(if(bin.start >= 4000, bin.density, 0)) as slow,
            `chrome-ux-report`.experimental.percentile(array_agg(bin), 75) as p75
        from base
        left join unnest(largest_contentful_paint.histogram.bin) as bin
        group by origin, network
    ),

    fid as (
        select
            origin,
            network,
            sum(if(bin.start < 100, bin.density, 0)) as fast,
            sum(if(bin.start >= 100 and bin.start < 300, bin.density, 0)) as avg,
            sum(if(bin.start >= 300, bin.density, 0)) as slow,
            `chrome-ux-report`.experimental.percentile(array_agg(bin), 75) as p75
        from base
        left join unnest(first_input.delay.histogram.bin) as bin
        group by origin, network
    ),

    fcp as (
        select
            origin,
            network,
            sum(if(bin.start < 1500, bin.density, 0)) as fast,
            sum(if(bin.start >= 1500 and bin.start < 2500, bin.density, 0)) as avg,
            sum(if(bin.start >= 2500, bin.density, 0)) as slow,
            `chrome-ux-report`.experimental.percentile(array_agg(bin), 75) as p75
        from base
        left join unnest(first_contentful_paint.histogram.bin) as bin
        group by origin, network
    ),

    ttfb as (
        select
            origin,
            network,
            sum(if(bin.start < 500, bin.density, 0)) as fast,
            sum(if(bin.start >= 500 and bin.start < 1500, bin.density, 0)) as avg,
            sum(if(bin.start >= 1500, bin.density, 0)) as slow,
            `chrome-ux-report`.experimental.percentile(array_agg(bin), 75) as p75
        from base
        left join unnest(time_to_first_byte.histogram.bin) as bin
        group by origin, network
    ),

    granular_metrics as (
        select
            origin,
            network,
            cls.small as small_cls,
            cls.medium as medium_cls,
            cls.large as large_cls,
            cls.p75 as p75_cls,

            lcp.fast as fast_lcp,
            lcp.avg as avg_lcp,
            lcp.slow as slow_lcp,
            lcp.p75 as p75_lcp,

            fid.fast as fast_fid,
            fid.avg as avg_fid,
            fid.slow as slow_fid,
            fid.p75 as p75_fid,

            fcp.fast as fast_fcp,
            fcp.avg as avg_fcp,
            fcp.slow as slow_fcp,
            fcp.p75 as p75_fcp,

            ttfb.fast as fast_ttfb,
            ttfb.avg as avg_ttfb,
            ttfb.slow as slow_ttfb,
            ttfb.p75 as p75_ttfb
        from cls
        left join lcp using(origin, network)
        left join fid using(origin, network)
        left join fcp using(origin, network)
        left join ttfb using(origin, network)
    )

select
    network,

    count(distinct origin) as total_origins,

    safe_divide(
        count(
            distinct if(
                is_good(fast_fid, avg_fid, slow_fid) and
                is_good(fast_lcp, avg_lcp, slow_lcp) and
                is_good(small_cls, medium_cls, large_cls),
                origin,
                null
            )
        ),
        count(
            distinct if(
                is_non_zero(fast_fid, avg_fid, slow_fid) and
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

from granular_metrics
group by network
