# standardSQL
# WebVitals distribution by device
with
    base as (
        select
            device,

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
        where device in ('desktop', 'phone') and date = '2020-08-01'
    ),

    fid as (
        select
            device,
            fast_fid,
            avg_fid,
            slow_fid,
            row_number() over (partition by device order by fast_fid desc) as row
        from
            (
                select
                    device,
                    safe_divide(fast_fid, fast_fid + avg_fid + slow_fid) as fast_fid,
                    safe_divide(avg_fid, fast_fid + avg_fid + slow_fid) as avg_fid,
                    safe_divide(slow_fid, fast_fid + avg_fid + slow_fid) as slow_fid,
                    row_number() over (
                        partition by device order by fast_fid desc
                    ) as row,
                    count(0) over (partition by device) as n
                from base
                where fast_fid + avg_fid + slow_fid > 0
            )
        where mod(row, cast(floor(n / 1000) as int64)) = 0
    ),

    lcp as (
        select
            device,
            fast_lcp,
            avg_lcp,
            slow_lcp,
            row_number() over (partition by device order by fast_lcp desc) as row
        from
            (
                select
                    device,
                    safe_divide(fast_lcp, fast_lcp + avg_lcp + slow_lcp) as fast_lcp,
                    safe_divide(avg_lcp, fast_lcp + avg_lcp + slow_lcp) as avg_lcp,
                    safe_divide(slow_lcp, fast_lcp + avg_lcp + slow_lcp) as slow_lcp,
                    row_number() over (
                        partition by device order by fast_lcp desc
                    ) as row,
                    count(0) over (partition by device) as n
                from base
                where fast_lcp + avg_lcp + slow_lcp > 0
            )
        where mod(row, cast(floor(n / 1000) as int64)) = 0
    ),

    cls as (
        select
            device,
            small_cls,
            medium_cls,
            large_cls,
            row_number() over (partition by device order by small_cls desc) as row
        from
            (
                select
                    device,
                    safe_divide(
                        small_cls, small_cls + medium_cls + large_cls
                    ) as small_cls,
                    safe_divide(
                        medium_cls, small_cls + medium_cls + large_cls
                    ) as medium_cls,
                    safe_divide(
                        large_cls, small_cls + medium_cls + large_cls
                    ) as large_cls,
                    row_number() over (
                        partition by device order by small_cls desc
                    ) as row,
                    count(0) over (partition by device) as n
                from base
                where small_cls + medium_cls + large_cls > 0
            )
        where mod(row, cast(floor(n / 1000) as int64)) = 0
    ),

    fcp as (
        select
            device,
            fast_fcp,
            avg_fcp,
            slow_fcp,
            row_number() over (partition by device order by fast_fcp desc) as row
        from
            (
                select
                    device,
                    safe_divide(fast_fcp, fast_fcp + avg_fcp + slow_fcp) as fast_fcp,
                    safe_divide(avg_fcp, fast_fcp + avg_fcp + slow_fcp) as avg_fcp,
                    safe_divide(slow_fcp, fast_fcp + avg_fcp + slow_fcp) as slow_fcp,
                    row_number() over (
                        partition by device order by fast_fcp desc
                    ) as row,
                    count(0) over (partition by device) as n
                from base
                where fast_fcp + avg_fcp + slow_fcp > 0
            )
        where mod(row, cast(floor(n / 1000) as int64)) = 0
    ),

    ttfb as (
        select
            device,
            fast_ttfb,
            avg_ttfb,
            slow_ttfb,
            row_number() over (partition by device order by fast_ttfb desc) as row
        from
            (
                select
                    device,
                    safe_divide(
                        fast_ttfb, fast_ttfb + avg_ttfb + slow_ttfb
                    ) as fast_ttfb,
                    safe_divide(avg_ttfb, fast_ttfb + avg_ttfb + slow_ttfb) as avg_ttfb,
                    safe_divide(
                        slow_ttfb, fast_ttfb + avg_ttfb + slow_ttfb
                    ) as slow_ttfb,
                    row_number() over (
                        partition by device order by fast_ttfb desc
                    ) as row,
                    count(0) over (partition by device) as n
                from base
                where fast_ttfb + avg_ttfb + slow_ttfb > 0
            )
        where mod(row, cast(floor(n / 1000) as int64)) = 0
    )

select
    device,
    row,

    fast_fid,
    avg_fid,
    slow_fid,

    small_cls,
    medium_cls,
    large_cls,

    fast_lcp,
    avg_lcp,
    slow_lcp,

    fast_fcp,
    avg_fcp,
    slow_fcp,

    fast_ttfb,
    avg_ttfb,
    slow_ttfb
from fid
full join lcp using (row, device)
full join cls using (row, device)
full join fcp using (row, device)
full join ttfb using (row, device)
order by device, row
