# standardSQL
# 04_09a: Client Hints
select
    client,
    countif(chhtml) as chhtmlcount,
    countif(chheader) as chheadercount,
    countif(chhtml and chheader) as chbothcount,
    countif(chhtml or chheader) as cheithercount,
    count(0) as total,
    round(100 * countif(chhtml) / count(0), 2) as chhtmlpct,
    round(100 * countif(chheader) / count(0), 2) as chheaderpct,
    round(100 * countif(chhtml and chheader) / count(0), 2) as chbothpct,
    round(100 * countif(chhtml or chheader) / count(0), 2) as cheitherpct
from
    (
        select
            client,
            page,
            regexp_contains(body, r'(?is)<meta[^><]*Accept-CH\b') as chhtml,
            regexp_contains(respotherheaders, r'(?is)Accept-CH = ') as chheader
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
group by client
