# standardSQL
# 09_06: % of pages having duplicate id attributes
select
    client,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    (
        select client, total, page, id, count(0) as freq
        from
            (
                select client, page, body
                from `httparchive.almanac.summary_response_bodies`
                where date = '2019-07-01' and firsthtml
            ),
            unnest(regexp_extract_all(body, '(?i)\\sid=[\'"]?([^\'"\\s]+)')) as id
        join
            (
                select _table_suffix as client, count(0) as total
                from `httparchive.pages.2019_07_01_*`
                group by _table_suffix
            ) using (client)
        group by client, total, page, id
    )
where freq > 1
group by client, total
