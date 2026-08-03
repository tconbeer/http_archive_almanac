# standardSQL
# 17_02f: % of Pages using a JS CDN Host
select
    client,
    countif(jscdnhits > 0) as hasjscdnhits,
    count(0) as hits,
    round(100 * countif(jscdnhits > 0) / count(0), 2) as pct
from
    (
        select
            client,
            page,
            countif(
                net.host(url) in (
                    'unpkg.com',
                    'www.jsdelivr.net',
                    'cdnjs.cloudflare.com',
                    'ajax.aspnetcdn.com',
                    'ajax.googleapis.com',
                    'stackpath.bootstrapcdn.com',
                    'maxcdn.bootstrapcdn.com',
                    'use.fontawesome.com',
                    'code.jquery.com',
                    'fonts.googleapis.com'
                )
            ) as jscdnhits
        from `httparchive.almanac.requests3`
        group by client, page
    )
group by client
order by client desc
