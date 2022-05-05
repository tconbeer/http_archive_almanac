# standardSQL
# 17_02g: % of Pages using a JS CDN Host
# doing the Pct calc causes memory problems with bigquery
select *, round(100 * pageusecount / totalpagescount, 2) as pct
from
    (
        select
            client,
            if(
                respbodysize > 0 and regexp_contains(
                    resp_content_type, r'javascript|css|font'
                ),
                net.host(url),
                null
            ) as host,
            count(distinct page) as pageusecount,
            sum(countif(firsthtml)) over (partition by client) as totalpagescount
        from `httparchive.almanac.requests3`
        group by client, host
    )
where host is not null and pageusecount > 1000
order by client desc, pageusecount desc
