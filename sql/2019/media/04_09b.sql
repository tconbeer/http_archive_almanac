# standardSQL
# 04_09b: Top Accept-CH
select client, chhtml, chheader, count(0) as hits
from
    (
        select
            client,
            page,
            replace(
                regexp_extract(
                    regexp_extract(body, r'(?is)<meta[^><]*Accept-CH\b[^><]*'),
                    r'(?im).*content=[&quot;#32"\']*([^\'"><]*)'
                ),
                '#32;',
                ''
            ) as chhtml,
            regexp_extract(
                regexp_extract(respotherheaders, r'(?is)Accept-CH = (.*)'),
                r'(?im)^([^=]*?)(?:, [a-z-]+ = .*)'
            ) as chheader
        from `httparchive.almanac.summary_response_bodies`
        where
            date = '2019-07-01'
            and firsthtml
            and (
                regexp_contains(body, r'(?is)<meta[^><]*Accept-CH\b')
                or regexp_contains(respotherheaders, r'(?is)Accept-CH = ')
            )
    )
group by client, chhtml, chheader
order by client desc, hits desc
