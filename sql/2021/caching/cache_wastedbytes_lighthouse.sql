# standardSQL
# Distribution of bytes wasted (absence of adequate caching) from Lighthouse
select
    _table_suffix as client,
    round(
        cast(
            json_extract_scalar(
                report, '$.audits.uses-long-cache-ttl.details.summary.wastedBytes'
            ) as numeric
        )
        / 1024
        / 1024
    ) as mbyte_savings,
    count(0) as num_pages,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct_pages
from `httparchive.lighthouse.2021_07_01_*`
group by client, mbyte_savings
order by client, mbyte_savings asc
