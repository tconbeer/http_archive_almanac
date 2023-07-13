# standardSQL
# Third-Party domains which render block paint
#
# Unlike the blocking main thread queries, light nhouse only contains details if the
# third-party is render blocking (i.e. wastedMs/total_bytes are never 0)
# And also there are no categories given to each third-party
# So we join to the usual almanac.third_parties table to get those totals and categories
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
    total_pages - count(distinct page) as non_blocking_pages,
    count(distinct page) / total_pages as blocking_pages_pct,
    (total_pages - count(distinct page)) / total_pages as non_blocking_pages_pct,
    approx_quantiles(wasted_ms, 1000)[offset(500)] as p50_wastedms,
    approx_quantiles(total_bytes_kib, 1000)[offset(500)] as p50_total_bytes_kib
from
    (
        select
            canonicaldomain,
            domain,
            page,
            category,
            sum(
                safe_cast(json_value(renderblockingitems, '$.wastedMs') as float64)
            ) as wasted_ms,
            sum(
                safe_cast(json_value(renderblockingitems, '$.totalBytes') as float64)
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
            ) as renderblockingitems
        inner join
            `httparchive.almanac.third_parties`
            on net.host(json_value(renderblockingitems, '$.url')) = domain
        group by canonicaldomain, domain, page, category
    )
inner join total_third_party_usage using (canonicaldomain, category)
group by canonicaldomain, category, total_pages
order by total_pages desc, category
limit 200
