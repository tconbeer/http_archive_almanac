# standardSQL
# variable_font_comparison_fcp
select
    client,
    variable_fonts > 0 as uses_variable_fonts,
    count(distinct if(variable_fonts > 0, page, null)) as pages_with_variable_fonts,
    total,
    count(distinct if(variable_fonts > 0, page, null)) / total as pct,
    approx_quantiles(fcp, 1000)[offset(500)] as median_fcp,
    approx_quantiles(lcp, 1000)[offset(500)] as median_lcp
from
    (
        select
            client,
            page,
            countif(
                regexp_contains(
                    json_extract(payload, '$._font_details.table_sizes'), '(?i)gvar'
                )
            ) as variable_fonts
        from `httparchive.almanac.requests`
        where date = '2020-09-01'
        group by client, page
    )
join
    (
        select
            _table_suffix as client,
            url as page,
            cast(
                json_extract_scalar(
                    payload, "$['_chromeUserTiming.firstContentfulPaint']"
                ) as int64
            ) as fcp,
            cast(
                json_extract_scalar(
                    payload, "$['_chromeUserTiming.LargestContentfulPaint']"
                ) as int64
            ) as lcp
        from `httparchive.pages.2020_09_01_*`
        group by _table_suffix, url, payload
    ) using (client, page)
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.pages.2020_09_01_*`
        group by _table_suffix
    ) using (client)
group by client, total, uses_variable_fonts
