# standardSQL
select
    substr(_table_suffix, 0, 10) as date,
    if(ends_with(_table_suffix, 'desktop'), 'desktop', 'mobile') as client,
    sum(if(starts_with(request, 'https'), 1, 0)) / count(0) as percent
from
    (
        select url as request, page as url, _table_suffix as _table_suffix
        from `httparchive.requests.*`
    )
group by date, client
order by date desc, client
