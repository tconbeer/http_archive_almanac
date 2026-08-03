# standardSQL
# popular_fonts_host_by_country
select client, country, host, pages, total, pct
from
    (
        select
            client,
            country,
            net.host(url) as host,
            count(distinct page) as pages,
            sum(count(distinct page)) over (partition by client) as total,
            count(distinct page)
            / sum(count(distinct page)) over (partition by client) as pct,
            row_number() over (
                partition by client, country order by count(distinct page) desc
            ) as sort_row
        from `httparchive.almanac.requests`
        join
            (
                select distinct
                    origin,
                    device,
                    `chrome-ux-report`.experimental.get_country(country_code) as country
                from `chrome-ux-report.materialized.country_summary`
                where yyyymm = 202008
            )
            on concat(origin, '/') = page
            and if(device = 'desktop', 'desktop', 'mobile') = client
        where type = 'font' and net.host(url) != net.host(page) and date = '2020-08-01'
        group by client, country, host
        order by pct desc
    )
where sort_row <= 1
