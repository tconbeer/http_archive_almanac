# standardSQL
# 04_09c: Top Client Hints
select client, ch, sum(hits) as hits
from
    (
        select
            client,
            regexp_replace(
                concat(ifnull(chhtml, ''), ',', ifnull(chheader, '')), r'^,|,$| ', ''
            ) as acceptch,
            count(0) as hits
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
                        '&#32;',
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
                        regexp_contains(body, r'(?im)<meta[^><]*Accept-CH\b')
                        or regexp_contains(respotherheaders, r'(?im)Accept-CH = ')
                    )
            )
        group by client, chhtml, chheader
    )
cross join unnest(split(lower(acceptch), ',')) as ch
group by client, ch
having ch != ''
order by client desc, hits desc
