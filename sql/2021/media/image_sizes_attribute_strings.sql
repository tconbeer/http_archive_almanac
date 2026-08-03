select
    client,
    sizes,
    count(0) as freq,
    sum(count(0)) over (partition by 0) as total,
    count(0) / sum(count(0)) over (partition by 0) as pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(
        regexp_extract_all(body, r'(?im)<(?:source|img)[^>]*sizes=[\'"]?([^\'"]*)')
    ) as sizes
where date = '2021-07-01' and firsthtml
group by client, sizes
order by freq desc
limit 100
