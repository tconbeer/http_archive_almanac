# standardSQL
# Image format popularity by CMS
select
    client,
    cms,
    any_value(pages) as pages,
    format,
    count(0) as freq,
    sum(count(0)) over (partition by client, cms) as total,
    count(0) / sum(count(0)) over (partition by client, cms) as pct
from
    (
        select distinct _table_suffix as client, url, app as cms
        from `httparchive.technologies.2021_07_01_*`
        where category = 'CMS'
    )
join
    (
        select
            client,
            page as url,
            if(
                mimetype = 'image/avif',
                'avif',
                if(mimetype = 'image/webp', 'webp', format)
            ) as format
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and type = 'image'
    )
    using
    (client, url)
join
    (
        select _table_suffix as client, app as cms, count(distinct url) as pages
        from `httparchive.technologies.2021_07_01_*`
        where category = 'CMS'
        group by client, cms
    )
    using
    (client, cms)
where pages > 1000
group by client, cms, format
order by freq desc
