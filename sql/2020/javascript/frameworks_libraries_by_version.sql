# standardSQL
# Top JS frameworks and libraries by version
select
    _table_suffix as client,
    category,
    app,
    info as version,
    count(distinct url) as pages,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2020_08_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where
    app in (
        'jQuery',
        'jQuery Migrate',
        'jQuery UI',
        'Modernizr',
        'FancyBox',
        'Slick',
        'Lightbox',
        'Moment.js',
        'Underscore.js',
        'Lodash',
        'React'
    )
group by client, category, app, info, total
order by pct desc
