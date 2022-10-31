# standardSQL
# 10_02: lang attribute usage and mistakes (lang='en')
# source:
# https://discuss.httparchive.org/t/what-are-the-invalid-uses-of-the-lang-attribute/1022
select
    client,
    lower(regexp_extract(body, '(?i)<html[^>]*lang=[\'"]?([a-z]{2})')) as lang,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.summary_response_bodies`
where date = '2019-07-01' and firsthtml
group by client, lang
order by freq / total desc
