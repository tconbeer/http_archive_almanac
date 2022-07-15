# standardSQL
# Third-Party domains which block the main thread by percentile
# 
# As Lighthouse measures all impact there is no need to do a separate total
# Lighthouse also gives a useable category. So no need to use almanac.third-parties
# table
# 
# Based heavily on research by Houssein Djirdeh:
# https://docs.google.com/spreadsheets/d/1Td-4qFjuBzxp8af_if5iBC0Lkqm_OROb7_2OcbxrU_g/edit?resourcekey=0-ZCfve5cngWxF0-sv5pLRzg#gid=1628564987
select
    domain,
    category,
    count(distinct page) as total_pages,
    countif(blocking > 0) as blocking_pages,
    percentile,
    approx_quantiles(
        transfer_size_kib, 1000) [offset (percentile * 10)
    ] as p50_transfer_size_kib,
    approx_quantiles(
        blocking_time, 1000) [offset (percentile * 10)
    ] as p50_blocking_time
from
    (
        select
            json_value(third_party_items, '$.entity.url') as domain,
            page,
            json_value(third_party_items, '$.entity.text') as category,
            countif(
                safe_cast(
                    json_value(
                        report, '$.audits.third-party-summary.details.summary.wastedMs'
                    ) as float64
                )
                > 250
            ) as blocking,
            sum(
                safe_cast(json_value(third_party_items, '$.blockingTime') as float64)
            ) as blocking_time,
            sum(
                safe_cast(json_value(third_party_items, '$.transferSize') as float64)
                / 1024
            ) as transfer_size_kib
        from
            (
                select url as page, report
                from `httparchive.lighthouse.2021_07_01_mobile`
            ),
            unnest(
                json_query_array(report, '$.audits.third-party-summary.details.items')
            ) as third_party_items
        group by domain, page, category
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by domain, category, percentile
having total_pages >= 50
order by total_pages desc, category, percentile
limit 200
