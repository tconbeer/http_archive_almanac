# standardSQL
# Histogram of JS bytes
select
    bin as kbytes,
    volume,
    round(pdf * 100, 2) as pdf,
    round(sum(pdf) over (order by bin) * 100, 2) as cdf
from
    (
        select *, volume / sum(volume) over () as pdf
        from
            (
                select
                    count(0) as volume,
                    cast(floor(bytesjs / 10240) * 10 as int64) as bin
                from `httparchive.summary_pages.2020_08_01_*`
                group by bin
            )
    )
order by bin
