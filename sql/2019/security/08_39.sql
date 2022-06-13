# standardSQL
# 08_39: SRI
select
    client,
    countif(regexp_contains(body, '(?i)<(?:link|script)[^>]*integrity=')) as freq,
    count(0) as total,
    round(
        countif(regexp_contains(body, '(?i)<(?:link|script)[^>]*integrity=')) / count(
            0
        ),
        2
    ) as pct
from `httparchive.almanac.summary_response_bodies`
where date = '2019-07-01' and firsthtml
group by client
