# standardSQL
select
    left(_table_suffix, 10) as month,
    if(ends_with(_table_suffix, '_desktop'), 'desktop', 'mobile') as client,
    count(0) as freq
from `httparchive.technologies.*`
where category = 'Cryptominers' or category = 'Cryptominer'
group by _table_suffix
order by client, month, freq desc
