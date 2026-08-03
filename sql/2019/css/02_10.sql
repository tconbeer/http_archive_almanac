# standardSQL
# 02_10: Top CSS libraries
select
    _table_suffix as client,
    app as library,
    count(0) as freq,
    total,
    round(count(0) * 100 / total, 2) as pct
from `httparchive.technologies.2019_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where
    app in (
        'animate.css',
        'Ant Design',
        'Bootstrap',
        'Bulma',
        'Clarity',
        'ZURB Foundation',
        'Angular Material',
        'Material Design Lite',
        'Materialize CSS',
        'Milligram',
        'Pure CSS',
        'Semantic-ui',
        'Shapecss',
        'tailwindcss',
        'UIKit'
    )
group by client, total, library
order by freq / total desc
