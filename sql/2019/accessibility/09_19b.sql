# standardSQL
# 09_19b: Top aria attributes
select
    client,
    split(regexp_replace(attr, '[\'"]', ''), '=')[offset(0)] as attribute,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(
        regexp_extract_all(lower(body), '<[^>]+\\b(aria-\\w+=[\'"]?[\\w-]+)')
    ) as attr
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.pages.2019_07_01_*`
        group by _table_suffix
    )
    using(client)
where date = '2019-07-01' and firsthtml
group by client, total, attribute
order by pages / total desc
