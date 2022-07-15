# standardSQL
# Median resource weights by SSG
select
    client,
    ssg,
    count(0) as pages,
    approx_quantiles(total_kb, 1000) [offset (500)] as median_total_kb,
    approx_quantiles(html_kb, 1000) [offset (500)] as median_html_kb,
    approx_quantiles(js_kb, 1000) [offset (500)] as median_js_kb,
    approx_quantiles(css_kb, 1000) [offset (500)] as median_css_kb,
    approx_quantiles(img_kb, 1000) [offset (500)] as median_img_kb,
    approx_quantiles(font_kb, 1000) [offset (500)] as median_font_kb
from
    (
        select distinct _table_suffix as client, url, app as ssg
        from `httparchive.technologies.2021_07_01_*`
        where
            lower(category) = 'static site generator'
            or app = 'Next.js'
            or app = 'Nuxt.js'
    )
join
    (
        select
            _table_suffix as client,
            url,
            bytestotal / 1024 as total_kb,
            byteshtml / 1024 as html_kb,
            bytesjs / 1024 as js_kb,
            bytescss / 1024 as css_kb,
            bytesimg / 1024 as img_kb,
            bytesfont / 1024 as font_kb
        from `httparchive.summary_pages.2021_07_01_*`
    )
    using
    (client, url)
group by client, ssg
order by pages desc
