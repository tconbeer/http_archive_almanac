# standardSQL
select
    left(_table_suffix, 10) as month,
    if(ends_with(_table_suffix, '_desktop'), 'desktop', 'mobile') as client,
    countif(category = 'Cryptominers' or category = 'Cryptominer') as freq,
    count(0) as total,
    countif(category = 'Cryptominers' or category = 'Cryptominer') / count(0) as pct
from `httparchive.technologies.*`
group by _table_suffix
order by client, month, pct desc
