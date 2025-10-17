# standardSQL
# 12_17: Histogram of mobile JS bytes (10kb buckets)
select bin, volume, pdf, sum(pdf) over (order by bin) as cdf
from
    (
        select *, volume / sum(volume) over () as pdf
        from
            (
                select
                    count(0) as volume,
                    cast(floor(bytesjs / 10240) * 10 as int64) as bin
                from `httparchive.summary_pages.2019_07_01_mobile`
                group by bin
            )
    )
order by bin
