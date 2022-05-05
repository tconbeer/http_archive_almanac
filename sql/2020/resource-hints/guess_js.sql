# standardSQL
# 21_05: Usage of Guess.js
select
    client,
    count(distinct if(regexp_contains(body, r'__GUESS__'), page, null)) as guess,
    count(0) as total,
    count(distinct if(regexp_contains(body, r'__GUESS__'), page, null)) / count(
        0
    ) as pct
from `httparchive.almanac.summary_response_bodies`
where date = '2020-08-01' and type = 'script'
group by client
