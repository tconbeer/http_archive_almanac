# standardSQL
# 17_02g: % of Pages using a library CDN Host
select *, round(100 * pageusecount / totalpagescount, 2) as pct
from
    (
        select
            client,
            if(
                net.host(url) in (
                    'unpkg.com',
                    'cdn.jsdelivr.net',
                    'cdnjs.cloudflare.com',
                    'ajax.aspnetcdn.com',
                    'ajax.googleapis.com',
                    'stackpath.bootstrapcdn.com',
                    'maxcdn.bootstrapcdn.com',
                    'use.fontawesome.com',
                    'code.jquery.com',
                    'fonts.googleapis.com'
                ),
                net.host(url),
                'OTHER'
            ) as jscdn,
            count(distinct page) as pageusecount,
            sum(countif(firsthtml)) over (partition by client) as totalpagescount
        from `httparchive.almanac.requests3`
        group by client, jscdn
    )
order by client desc, pageusecount desc
