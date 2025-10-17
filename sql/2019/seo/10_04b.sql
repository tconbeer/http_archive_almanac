# standardSQL
# 10_04b: hreflang implementation values
select
    client,
    normalize_and_casefold(trim(hreflang)) as hreflang,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(
        regexp_extract_all(body, '(?i)<link[^>]*hreflang=[\'"]?([^\'"\\s>]+)')
    ) as hreflang
where date = '2019-07-01'
group by client, hreflang
order by freq / total desc
limit 10000
