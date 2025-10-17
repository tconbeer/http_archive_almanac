# standardSQL
# 04_06b: Usage of source[sizes]
select
    client,
    sizes,
    count(0) as freq,
    sum(count(0)) over () as total,
    round(count(0) * 100 / sum(count(0)) over (), 2) as pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(
        regexp_extract_all(body, r'(?im)<(?:source|img)[^>]*sizes=[\'"]?([^\'"]*)')
    ) as sizes
where date = '2019-07-01' and firsthtml
group by client, sizes
order by client desc, freq desc
