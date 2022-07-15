# standardSQL
# ECT distribution
select
    device,
    percentile,
    approx_quantiles(
        _4gdensity / (
            _4gdensity + _3gdensity + _2gdensity + slow2gdensity + offlinedensity
        ),
        1000
    ) [offset (percentile * 10)
    ] as _4gdensity,
    approx_quantiles(
        _3gdensity / (
            _4gdensity + _3gdensity + _2gdensity + slow2gdensity + offlinedensity
        ),
        1000
    ) [offset (percentile * 10)
    ] as _3gdensity,
    approx_quantiles(
        _2gdensity / (
            _4gdensity + _3gdensity + _2gdensity + slow2gdensity + offlinedensity
        ),
        1000
    ) [offset (percentile * 10)
    ] as _2gdensity,
    approx_quantiles(
        slow2gdensity / (
            _4gdensity + _3gdensity + _2gdensity + slow2gdensity + offlinedensity
        ),
        1000
    ) [offset (percentile * 10)
    ] as slow2gdensity,
    approx_quantiles(
        offlinedensity / (
            _4gdensity + _3gdensity + _2gdensity + slow2gdensity + offlinedensity
        ),
        1000
    ) [offset (percentile * 10)
    ] as offlinedensity
from
    `chrome-ux-report.materialized.device_summary`,
    unnest(generate_array(1, 100)) as percentile
where date = '2020-08-01'
group by device, percentile
order by device, percentile
