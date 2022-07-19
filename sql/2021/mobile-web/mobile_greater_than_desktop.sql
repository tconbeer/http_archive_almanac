# standardSQL
# Percentage of websites receiving more traffic from mobile than desktop. Tablet is
# excluded since it does not fit well in either category
with
    base as (
        select date, origin, rank, desktopdensity, phonedensity
        from `chrome-ux-report.materialized.metrics_summary`
        where date in ('2021-07-01')
    )

select
    date,
    case
        when rank_grouping = 10000000 then 'all' else cast(rank_grouping as string)
    end as ranking,

    count(distinct origin) as total_origins,

    count(distinct if(desktopdensity = phonedensity, origin, null)) as total_equal,
    count(
        distinct if(desktopdensity < phonedensity, origin, null)
    ) as total_more_mobile,
    count(
        distinct if(desktopdensity > phonedensity, origin, null)
    ) as total_more_desktop,

    safe_divide(
        count(distinct if(desktopdensity = phonedensity, origin, null)),
        count(distinct origin)
    ) as perc_equal,
    safe_divide(
        count(distinct if(desktopdensity < phonedensity, origin, null)),
        count(distinct origin)
    ) as perc_more_mobile,
    safe_divide(
        count(distinct if(desktopdensity > phonedensity, origin, null)),
        count(distinct origin)
    ) as perc_more_desktop
from base, unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
where rank <= rank_grouping
group by date, rank_grouping
order by rank_grouping
