# standardSQL
# 04_26: Usage of <img loading=lazy>
select
    client,
    countif(
        regexp_contains(body, r'(?im)<(?:source|img)[^>]*loading=[\'"]?lazy')
    ) as lazycount,
    count(0) as freq
from `httparchive.almanac.summary_response_bodies`
where date = '2019-07-01' and firsthtml
group by client
order by client desc
