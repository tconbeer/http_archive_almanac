# standardSQL
# Adoption of image formats in SSGs
select
    client,
    format,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select client, format, page
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and type = 'image'
    )
join
    (
        select _table_suffix as client, url as page
        from `httparchive.technologies.2020_08_01_*`
        where
            lower(category) = 'static site generator'
            or app = 'Next.js'
            or app = 'Nuxt.js'
            or app = 'Docusaurus'
    ) using (client, page)
group by client, format
order by pct desc
