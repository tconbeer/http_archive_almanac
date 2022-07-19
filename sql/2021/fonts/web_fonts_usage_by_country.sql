# standardSQL
# web_fonts_usage_by_country
select
    _table_suffix as client,
    country,
    count(0) as freq_url,
    approx_quantiles(bytesfont, 1000)[offset(500)] / 1024 as median_font_kbytes
from
    (
        select distinct
            origin,
            device,
            `chrome-ux-report`.experimental.get_country(country_code) as country
        from `chrome-ux-report.materialized.country_summary`
        where yyyymm = 202107
    )
join
    `httparchive.summary_pages.2021_07_01_*`
    on concat(origin, '/') = url
    and if(device = 'desktop', 'desktop', 'mobile') = _table_suffix
where bytesfont is not null
group by client, country
order by client, country
