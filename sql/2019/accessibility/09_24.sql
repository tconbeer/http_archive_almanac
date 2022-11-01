# standardSQL
# 09_24: % pages with aria-posinset and aria-setsize
select
    client,
    countif(posinset and setsize) as freq,
    count(0) as total,
    round(countif(posinset and setsize) * 100 / count(0), 2) as pct
from
    (
        select
            client,
            regexp_contains(body, '\\saria-posinset=') as posinset,
            regexp_contains(body, '\\saria-setsize=') as setsize
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
group by client
order by freq / total desc
