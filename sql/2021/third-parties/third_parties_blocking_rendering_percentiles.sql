# standardSQL
# Third-Party domains which render block paint by percentile
# 
# Unlike the blocking main thread queries, light nhouse only contains details if the
# third-party is render blocking (i.e. wastedMs/total_bytes are never 0)
# And also there are no categories given to each third-party
# So we join to the usual almanac.third_parties table to get those totals and
# categories
# 
# Based heavily on research by Houssein Djirdeh:
# https://docs.google.com/spreadsheets/d/1Td-4qFjuBzxp8af_if5iBC0Lkqm_OROb7_2OcbxrU_g/edit?resourcekey=0-ZCfve5cngWxF0-sv5pLRzg#gid=1628564987
with
    total_third_party_usage as (
        select canonicaldomain, category, count(distinct sp.url) as total_pages
        from `httparchive.summary_pages.2021_07_01_mobile` sp
        inner join `httparchive.summary_requests.2021_07_01_mobile` sr using (pageid)
        inner join
            `httparchive.almanac.third_parties`
            on net.host(sr.url) = net.host(domain)
            and date = '2021-07-01'
            and category != 'hosting'
        group by canonicaldomain, category
        having total_pages >= 50
    )

select
    canonicaldomain,
    category,
    total_pages,
    count(distinct page) as blocking_pages,
    percentile,
    approx_quantiles(wasted_ms, 1000)[offset(percentile * 10)] as wasted_ms,
    approx_quantiles(total_bytes_kib, 1000)[offset(percentile * 10)] as total_bytes_kib
from
    (
        select
            canonicaldomain,
            page,
            category,
            sum(
                safe_cast(json_value(render_blocking_items, '$.wastedMs') as float64)
            ) as wasted_ms,
            sum(
                safe_cast(json_value(render_blocking_items, '$.totalBytes') as float64)
                / 1024
            ) as total_bytes_kib
        from
            (
                select url as page, report
                from `httparchive.lighthouse.2021_07_01_mobile`
            ),
            unnest(
                json_query_array(
                    report, '$.audits.render-blocking-resources.details.items'
                )
            ) as render_blocking_items
        inner join
            `httparchive.almanac.third_parties`
            on net.host(json_value(render_blocking_items, '$.url')) = domain
            and date = '2021-07-01'
        group by canonicaldomain, page, category
    )
inner join
    total_third_party_usage using (canonicaldomain, category),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by canonicaldomain, category, total_pages, percentile
order by total_pages desc, category, percentile
limit 200
