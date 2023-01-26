# standardSQL
# 10_04a: has hreflang
select
    client,
    countif(has_hreflang) as freq,
    count(0) as total,
    round(countif(has_hreflang) * 100 / count(0), 2) as pct
from
    (
        select client, regexp_contains(body, '(?i)<link[^>]*hreflang') as has_hreflang
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
group by client
