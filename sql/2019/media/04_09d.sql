# standardSQL
# 04_09c: Top Client Hints
select
    client,
    countif(
        regex_contains(body, r'(?is)<meta[^><]*Accept-CH\b')
        or regexp_contains(respotherheaders, r'(?im)Accept-CH = ')
    ) as acceptfreq,
    count(0) as total
from `httparchive.almanac.summary_response_bodies`
where
    date = '2019-07-01'
    and firsthtml
    and regexp_contains(body, r'(?im)<(?:source|img)[^>]*sizes=[\'"]?([^\'"]*)')
group by client
order by client desc, total desc
