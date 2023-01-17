# standardSQL
# 01_01d: Histogram of JS bytes by client
select
    bin as kbytes,
    client,
    volume,
    round(pdf * 100, 2) as pdf,
    round(sum(pdf) over (partition by client order by bin) * 100, 2) as cdf
from
    (
        select *, volume / sum(volume) over (partition by client) as pdf
        from
            (
                select
                    _table_suffix as client,
                    count(0) as volume,
                    cast(floor(bytesjs / 10240) * 10 as int64) as bin
                from `httparchive.summary_pages.2019_07_01_*`
                group by bin, client
            )
    )
order by bin, client
