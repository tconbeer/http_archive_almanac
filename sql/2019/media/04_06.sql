# standardSQL
# 04_06: Pages with source[sizes]
select
    client,
    countif(hassizes) as hassizes,
    countif(hassrcset) as hassrcset,
    countif(haspicture) as haspicture,
    count(0) as total,
    round(countif(hassizes) * 100 / count(0), 2) as pctsizes,
    round(countif(hassrcset) * 100 / count(0), 2) as pctsrcset,
    round(countif(haspicture) * 100 / count(0), 2) as pctpicture,
    round(
        countif(haspicture or hassrcset or hassizes) * 100 / count(0), 2
    ) as anyrespimg
from
    (
        select
            client,
            regexp_contains(
                body, r'(?is)<(?:img|source)[^>]*sizes=[\'"]?([^\'"]*)'
            ) as hassizes,
            regexp_contains(
                body, r'(?is)<(?:img|source)[^>]*srcset=[\'"]?([^\'"]*)'
            ) as hassrcset,
            regexp_contains(body, r'(?si)<picture.*?<img.*?/picture>') as haspicture
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
group by client
order by client desc
