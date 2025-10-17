# standardSQL
# 09_22: % pages with aria-hidden on body
select
    client,
    countif(hides_body) as freq,
    count(0) as total,
    round(countif(hides_body) * 100 / count(0), 2) as pct
from
    (
        select client, regexp_contains(body, '<body[^>]+aria-hidden') as hides_body
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
group by client
order by freq / total desc
