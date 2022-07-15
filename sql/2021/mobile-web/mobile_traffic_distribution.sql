# standardSQL
# Distribution of traffic coming from mobile devices
select
    percentile,
    approx_quantiles(
        phonedensity, 1000) [offset (percentile * 10)
    ] as pct_traffic_from_mobile
from
    `chrome-ux-report.materialized.device_summary`,
    unnest(generate_array(1, 100)) as percentile
where date = '2021-07-01' and device = 'phone'
group by percentile
order by percentile
