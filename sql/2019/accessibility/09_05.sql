# standardSQL
# 09_05: ARIA role popularity
select
    client,
    role,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(regexp_extract_all(lower(body), 'role=[\'"]?([\\w-]+)')) as role
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
where date = '2019-07-01' and firsthtml
group by client, total, role
order by pages / total desc
limit 1000
