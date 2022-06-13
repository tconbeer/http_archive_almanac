# standardSQL
# lighthouse_compression_byte_savings.sql :  Text Based Compression Byte Savings
select
    _table_suffix as client,
    round(
        cast(
            json_extract_scalar(
                report, '$.audits.uses-text-compression.details.overallSavingsBytes'
            ) as int64
        ) / 1024 / 1024
    ) as mbyte_savings,
    count(0) as num_pages,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct_pages
from `httparchive.lighthouse.2021_07_01_*`
where json_extract_scalar(report, '$.audits.uses-text-compression.score') != '1'
group by client, mbyte_savings
order by client, mbyte_savings
