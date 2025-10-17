# standardSQL
# Text Based Compression Byte Savings
select
    _table_suffix as client,
    if(
        json_extract_scalar(report, '$.audits.uses-text-compression.score') != '1',
        'compression',
        'non_compression'
    ) as compression,
    percents,
    approx_quantiles(
        (
            cast(
                json_extract_scalar(
                    report, '$.audits.uses-text-compression.details.overallSavingsBytes'
                ) as int64
            )
            / 1024
        ),
        1000
    )[offset(percents * 10)] as kbyte_savings
from `httparchive.lighthouse.2020_08_01_*`, unnest([10, 25, 50, 75, 90]) as percents
where report is not null
group by _table_suffix, compression, percents
order by _table_suffix, percents asc
