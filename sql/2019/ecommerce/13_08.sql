# standardSQL
# 13_08: CrUX FCP performance of ecommerce providers
select
    app,
    count(distinct origin) as freq,
    if(form_factor.name = 'desktop', 'desktop', 'mobile') as form_factor,
    round(sum(if(bin.start < 1000, bin.density, 0)) / sum(bin.density), 4) as fast,
    round(
        sum(if(bin.start >= 1000 and bin.start < 2500, bin.density, 0)) / sum(
            bin.density
        ),
        4
    ) as avg,
    round(sum(if(bin.start >= 2500, bin.density, 0)) / sum(bin.density), 4) as slow
from `chrome-ux-report.all.201907`, unnest(first_contentful_paint.histogram.bin) as bin
join
    (
        select _table_suffix as client, url, app
        from `httparchive.technologies.2019_07_01_*`
        where category = 'Ecommerce'
        group by client, url, app
    ) on concat(origin, '/') = url and if(
        form_factor.name = 'desktop', 'desktop', 'mobile'
    ) = client
group by app, form_factor
order by freq desc
