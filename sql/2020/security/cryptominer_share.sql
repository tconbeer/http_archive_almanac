# standardSQL
# Share of cryptominers
select
    app,
    _table_suffix as client,
    sum(count(0)) over (partition by _table_suffix) as total_cryptominers,
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.technologies.2020_08_01_*`
where category = 'Cryptominers' or category = 'Cryptominer'
group by client, app
order by client, pct desc
