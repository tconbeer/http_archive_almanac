# standardSQL
# 09_16: % pages using invalid/required form field attributes
select
    client,
    attr,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(
        array_concat(
            regexp_extract_all(body, '<input[^>]+(aria-invalid|aria-required)\\b'),
            regexp_extract_all(body, '<input[^>]+[^-](required)\\b')
        )
    ) as attr
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.pages.2019_07_01_*`
        group by _table_suffix
    )
    using(client)
where date = '2019-07-01' and firsthtml
group by client, total, attr
order by pages / total desc
